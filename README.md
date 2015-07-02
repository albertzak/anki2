# Anki<sup>2</sup>

Create Anki Flashcards with Ruby! Supports images, audio, HTML and CSS.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'anki2'
```

And then execute:

    $ bundle

## Usage

Let's make your first deck.

```ruby
@anki = Anki2.new
@anki.add_card('Are Walruses magical?', 'Yes')
@anki.add_card('What animals are magical?', 'Unicorns and Walruses')
@anki.save
```

This will save the deck in the default location `anki/deck.apkg`.
Change the output path like this:

```ruby
@anki = Anki2.new({
  name: 'Magical Animals', 
  output_path: 'public/MagicalAnimals.apkg'
})
```

Congratulations!

### Images

Let's make a flashcard with an image. Put a picture of a blobfish ([here's one](http://conservationmagazine.org/wordpress/wp-content/uploads/2013/11/blobfish.jpg)) into a subfolder called `images`.

```ruby
@anki = Anki2.new
@anki.add_card(
  'What is this animal called? <img src="blobfish.jpg">',
  'A Blobfish'
)
@anki.add_media('images/blobfish.jpg')
@anki.save
```

Yay! If you have a lot of cards with a lot of images, just call `add_media` once and give it a path to the directory that contains your media. All the files from that directory will be included and are available in the deck, like so:

```ruby
@anki.add_card('<img src="front.jpg">','<img src="back.jpg">')
@anki.add_media('images')
@anki.save
```

### Audio

```ruby
@anki = Anki2.new
@anki.add_card('よ[audio:yo.mp3]','yo')
@anki.add_media('yo.mp3')
@anki.save
```

### CSS + HTML

```ruby
@anki = Anki2.new(css: '.kanji { font-size: 88px; }')
@anki.add_card('<span class="kanji">大</span>', 'Big')
@anki.save
```

Feel free to get crazy.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Bugs

Here's a list of things that don't work yet:
  
  - Tags
  - Subdecks
  - Modifying the model: fields and card templates
  - Reading/Modifying existing decks
  - The structure of the code could use some love
  - And maybe add some tests?

Much Love to you if you contribute and fix one of them.
Or just open an issue here if you really want to do something that the gem doesn't do yet - I'll be glad to help.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/anki2/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
6. Thank you 💕
