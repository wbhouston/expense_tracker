{
  ym: '%Y %m',
}.each do |key, format|
  Date::DATE_FORMATS[:ym] = '%Y %B'
  Time::DATE_FORMATS[:ym] = '%Y %B'
end