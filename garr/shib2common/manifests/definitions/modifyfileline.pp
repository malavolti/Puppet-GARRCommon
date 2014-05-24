define modifyfilelines($modifyname = '', $filename, $filepath, $search, $replace, $search_new = true) {
  if ($search_new) {
    $grep_replace = regsubst($replace, '\\/', '/')
    $var_unless = "grep \"${grep_replace}\" ${filename}"
    $var_onlyif = undef
  }
  else {
    $grep_replace = regsubst($search, '\\/', '/')
    $var_unless = undef
    $var_onlyif = "grep \"${grep_replace}\" ${filename}"
  }
  
  exec {
    "modify ${filename} ${modifyname}":
      command => "sed -i -e\"s/${search}/${replace}/\" ${filename}",
      unless  => $var_unless,
      onlyif  => $var_onlyif,
      cwd     => $filepath,
      path    => ["/bin", "/usr/bin"],
  }
}