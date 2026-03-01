# Run Flutter with --dart-define from .env (copy .env.example to .env first).
$dartDefines = @()
if (Test-Path .env) {
  Get-Content .env | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith('#')) {
      $i = $line.IndexOf('=')
      if ($i -gt 0) {
        $key = $line.Substring(0, $i).Trim()
        $val = $line.Substring($i + 1).Trim().Trim('"').Trim("'")
        if ($key -eq 'GROQ_API_KEY' -or $key -eq 'SUPABASE_URL' -or $key -eq 'SUPABASE_ANON_KEY') {
          $dartDefines += "--dart-define=$key=$val"
        }
      }
    }
  }
}
$allArgs = $dartDefines + $args
& flutter run @allArgs
