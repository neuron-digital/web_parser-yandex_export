## web_parser-yandex_export

##### gem для получения информации о погоде и пробках с портала http://export.yandex.ru
---

### Установка

1\. Подключить гем в Gemfile

```ruby
gem 'web_parser-yandex_export', git: 'git@git.nnbs.ru:gem/web_parser-yandex_export.git', tag: 'v0.0.1'
```

В качестве тега, возможно, потребуется указать более свежую версию. Последняя версия на момент написания данного файла «v0.0.1»

2\. Выполнить команду в терминале 

```bash
$ bundle
```

### Использование

Для получения погоды на день

```ruby
WebParser::YandexExport.day_weather
```

Для получения свежей информации о пробках

```ruby
WebParser::YandexExport.traffic
```

###### **This project rocks and uses MIT-LICENSE.**