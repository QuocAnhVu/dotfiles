#!/usr/bin/env nu

export def count [interval: duration, filepattern: glob] {
  mut user_words = 0;
  mut ai_words = 0;
  for filename in (glob $filepattern) {
    $user_words += (cat $filename
    | from json -o
    | skip 1
    | update send_date { into datetime }
    | where send_date >= (date now) - $interval
    | where name == "User"
    | select mes
    | each {|x| $x.mes | str stats | get words }
    | try { math sum } catch { 0 })
    $ai_words += (cat $filename
    | from json -o
    | skip 1
    | update send_date { into datetime }
    | where send_date >= (date now) - $interval
    | where name != "User"
    | select mes
    | each {|x| $x.mes | str stats | get words }
    | try { math sum } catch { 0 })
  }
  { User: $user_words,
    AI: $ai_words,
  }
}
