require 'anki2/version'
require 'json'
require 'fileutils'
require 'digest/sha1'
require 'sqlite3'
require 'zip'

class Anki2

  SEPARATOR = "\u001F"

  attr_accessor :options

  def initialize(options = {})
    @options = {
      output_path: File.join('anki', 'deck.apkg'),
      name: 'Anki2 Rubygem Deck',
      template_sql_path: File.join(File.dirname(__FILE__), 'template.sql'),
    }.merge(options)

    @options[:model_name] = @options[:name] unless @options[:model_name]
    @options[:css] = default_css + @options[:css].to_s
    @options[:model] = model_config.call(default_model) if block_given?

    @media = []

    FileUtils.mkdir_p(File.dirname(@options[:output_path]))
    @tmpdir = Dir.mktmpdir

    @db = SQLite3::Database.open(File.join(@tmpdir, 'collection.anki2'))
    @db.execute_batch File.read(@options[:template_sql_path])

    @top_deck_id = rand(10**13)
    decks  = @db.execute('select decks from col')
    decks  = JSON.parse(decks.first.first.gsub('\"', '"'))
    deck   = decks.delete(decks.keys.last)
    deck['name'] = @options[:name]
    deck['id']   = @top_deck_id
    decks[@top_deck_id.to_s] = deck
    @db.execute('update col set decks=? where id=1', decks.to_json)

    @top_model_id = rand(10**13)
    models = @db.execute('select models from col')
    models = JSON.parse(models.first.first.gsub('\"', '"'))
    model  = models.delete(models.keys.first)

    if @options[:model]
      model = @options[:model]
    else
      model['name'] = @options[:model_name]
      model['css']  = @options[:css]
    end

    model['did']  = @top_deck_id
    model['id']   = @top_model_id
    models[@top_model_id.to_s] = model
    @db.execute('update col set models=? where id=1', models.to_json)
  end

  def find_or_create_deck(deck_name)
    existing_decks = {}

    decks  = @db.execute('select decks from col')
    decks  = JSON.parse(decks.first.first.gsub('\"', '"'))
    decks.each_pair do |id, deck|
      next if id.eql?(1)
      existing_decks[deck['name']] = id
    end

    if existing_decks.keys.any? { |name| name.eql?(deck_name) }
      id = existing_decks[deck_name]
    else
      id = rand(10**13)
      new_deck = decks[decks.keys.last]
      new_deck['name'] = deck_name
      new_deck['id'] = id
      decks[id.to_s] = new_deck
      @db.execute('update col set decks=? where id=1', decks.to_json)
      add_model_for_deck(id)
    end

    id
  end

  def add_card(front, back, tags = [], deck = nil)

    if deck.is_a?(String)
      deck = [@options[:name], deck].join('::')
      puts deck
      deck_id = find_or_create_deck(deck)
    elsif deck.is_a?(Integer)
      deck_id = deck
    else
      deck_id = @top_deck_id
    end

    note_id = rand(10**13)
    tags = tags.map { |t| t.tr(' ','_')}.join(' ')

    @db.execute "insert into notes values(?,?,?,?,?,?,?,?,?,?,?)", 
      note_id,
      rand(10**10).to_s(36),
      @top_model_id,
      Time.now.to_i,-1,
      tags,
      front + SEPARATOR + back,
      strip_html(front),
      checksum(strip_html(front+SEPARATOR+back)),
      0,''

    @db.execute "insert into cards values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
      rand(10**13),
      note_id,
      deck_id,
      0,
      Time.now.to_i,
      -1,0,0,179,0,0,0,0,0,0,0,0,''

    true
  end

  def add_media(media_path)
    if File.directory?(media_path)
      Dir.glob(File.join(media_path, '**.**')).each do |single_media_path|
        copy_media(single_media_path)
      end
    else
      copy_media(media_path)
    end
  end

  def save
    tmp_media = []
    @media.each do |media|
      tmp_media << '"' + media[:index] + '": "' + media[:filename] + '"'
    end
    File.open(File.join(@tmpdir, 'media'), 'a') { |f| f.puts '{' + tmp_media.join(', ') + '}' }

    FileUtils.mkdir_p(File.dirname(@options[:output_path]))
    File.delete(@options[:output_path]) if File.exist?(@options[:output_path])
    Zip::File.open(@options[:output_path], Zip::File::CREATE) do |zip|
      Dir.glob(File.join(@tmpdir, '**')).each do |file_path|
        zip.add(File.basename(file_path), file_path)
      end
    end

    @db.close if @db
    FileUtils.rm_rf(@tmpdir) if File.exist?(@tmpdir)

    @options[:output_path]
  end

  private

  def add_model_for_deck(deck_id)
    model_id = rand(10**13)
    models = @db.execute('select models from col')
    models = JSON.parse(models.first.first.gsub('\"', '"'))
    model  = models[models.keys.first]
    model['name'] = @options[:model_name]
    model['did']  = deck_id
    model['id']   = model_id
    model['css']  = @options[:css]
    models[model_id.to_s] = model
    model_id
  end

  def copy_media(source_path)
    raise Errno::ENOENT.new(source_path) unless File.exist?(source_path)
    destination_path = File.join(@tmpdir, @media.count.to_s)
    FileUtils.cp(source_path, destination_path)
    @media << { index: @media.count.to_s, filename: File.basename(source_path) }
    true
  end

  def checksum(str)
    Digest::SHA1.hexdigest(str)[0...8].to_i(16)
  end

  def strip_html(str)
    str
  end

  def default_css
    <<-CSS
      .card {
       font-family: arial;
       font-size: 20px;
       text-align: center;
       color: black;
      }
    CSS
  end

  def default_model
    {
      'name' => 'Anki2 Rubygem Template',
      'flds' => [
        {
          'name'   => 'Front',
          'rtl'    => false,
          'sticky' => false,
          'media'  => [],
          'ord'    => 0,
          'font'   => 'Arial',
          'size'   => 12
        },
        {
          'name'   => 'Back',
          'rtl'    => false,
          'sticky' => false,
          'media'  => [],
          'ord'    => 0,
          'font'   => 'Arial',
          'size'   => 12
        }
      ],
      'tmpls' => [
        {
          'name'  => 'Forward',
          'qfmt'  => '{{Front}}',
          'did'   => nil,
          'bafmt' => '',
          'afmt'  => '{{Back}}',
          'ord'   => 0,
          'bqfmt' => ''
        }
      ],
    }
  end
end
