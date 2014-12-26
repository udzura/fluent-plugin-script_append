# Fluent::Plugin::ScriptAppend

A fluent plugin to add script-run result to existing json data

## Installation

Install it yourself as:

    $ fluent-gem install fluent-plugin-script_append

## Usage

```conf
<match access.foo>
  type script_append
  # currently only ruby supported
  language ruby
  run_script record['one'].to_i + record['two'].to_i
  key three
</match>
```

Input:

```json
{
  "one" : 1,
  "twe" : 2
}
```

Then get emitted:

```json
{
  "one" : 1,
  "twe" : 2,
  "three" : 3
}
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/fluent-plugin-script_append/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
