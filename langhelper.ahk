; Toggle swe/en characters
lang := "en"

!t:: ToggleChars()

ToggleChars() {
  global lang
  if (lang == "swe")
    lang := "en"
  else
    lang := "swe"
}

; "Translate" keys
$`;:: TranslateKey(";")
$+`;:: TranslateKey(":")
$':: TranslateKey("'")
$+':: TranslateKey("""")
$[:: TranslateKey("[")
$+[:: TranslateKey("{")
$!`;:: Send, `;
$!+`;:: Send, :
$!':: Send, '
$!+':: Send, "
$![:: Send, [
$!+[:: Send, {{}

TranslateKey(key) {
  global lang
  if (lang == "swe") {
    if (key == ";")
        SendInput, {U+00F6}
    else if (key == ":")
      SendInput, {U+00D6}
    else if (key == "'")
      SendInput, {U+00E4}
    else if (key == """")
      SendInput, {U+00C4}
    else if (key == "[")
      SendInput, {U+00E5}
    else if (key == "{")
      SendInput, {U+00C5}
  }
  else {
    if (key == ";")
      SendInput, `;
    else if (key == ":")
      SendInput, :
    else if (key == "'")
      SendInput, '
    else if (key == """")
      SendInput, "
    else if (key == "[")
      SendInput, [
    else if (key == "{")
      SendInput, {{}
  }
}
