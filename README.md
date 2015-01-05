# Fluent::Plugin::ScriptAppend

A fluent plugin to add script-run result to existing json data

[![wercker status](https://app.wercker.com/status/56186aa7c9f166ffea49aba97971e40d/m "wercker status")](https://app.wercker.com/project/bykey/56186aa7c9f166ffea49aba97971e40d)

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
  "two" : 2
}
```

Then get emitted:

```json
{
  "one" : 1,
  "two" : 2,
  "three" : 3
}
```

## Parameters

* `key`, A key for added record to use in json. Required
* `language`, A language of script, default to ruby, available: `ruby, sh(ell)`
    * In `language ruby`, the record to add is the value of specified expression
    * In `language shell`, the record to add is the stdout of specified shell script
* `run_script`, A script for generating data. Required
* `record_var_name`, A variable name for original json data in `ruby` script. Default to `record`
* `new_tag`, A tag name to use in new emissions
* `prefix`, A tag prefix to add original tag in new emissions. `new_tag` or `prefix` is required

## Contributing

1. Fork it ( https://github.com/[my-github-username]/fluent-plugin-script_append/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
