### -- Output options --------------------------------------------------------

$quiet  = 1;
$silent = 1;

# -- Build options -----------------------------------------------------------

$pdf_mode = 4;       # PDF LuaLaTeX
$aux_dir  = "build"; # Build in this folder...
$emulate_aux = 1;    # and move PDF in root (`$out_dir`)
# Force reproducible  builds
# Source: https://tex.stackexchange.com/questions/229605
$pretex    = '\pdfvariable suppressoptionalinfo 512\relax';
$usepretex = 1;

# -- Additional rules --------------------------------------------------------

# `bib2gls` for glossaries
add_cus_dep('aux', 'glstex', 0, 'run_bib2gls');

sub run_bib2gls {
  my ($base, $path) = fileparse($_[0]);
  my $silent_command = $silent ? "--silent" : "";
  if ($path) {
    my $ret = system("bib2gls $silent_command -d '$path' --group '$base'");
  }
  else {
    my $ret = system("bib2gls $silent_command --group '$_[0]'");
  }
  # Analyze log file
  local *LOG;
  $LOG = "$_[0].glg";
  if (!$ret && -e $LOG) {
    open LOG, "<$LOG";
    while (<LOG>) {
      if (/^Reading (.*\.bib)\s$/) {
        rdb_ensure_file($rule, $1);
      }
    }
    close LOG;
  }
  return $ret;
}

# TikZ `externalize`
# Source: https://tex.stackexchange.com/a/444224
$clean_ext .= ' %R.figlist %R-figure* %R.makefile fls.tmp';
$lualatex                        = 'internal tikzlatex lualatex %B %O %S';
$hash_calc_ignore_pattern{'pdf'} = '^(/CreationDate|/ModDate|/ID)';
$hash_calc_ignore_pattern{'ps'}  = '^%%CreationDate';

sub tikzlatex {
  my ($engine, $base, @args) = @_;
  my $ret = 0;
  print "Tikzlatex: Running '$engine @args'...\n";
  $ret = system($engine, @args);
  print "Tikzlatex: Fixing '.fls' file ...\n";
  system
    "echo INPUT \"$aux_dir1$base.figlist\"  >  \"$aux_dir1$base.fls.tmp\"";
  system
    "echo INPUT \"$aux_dir1$base.makefile\" >> \"$aux_dir1$base.fls.tmp\"";
  system
    "cat \"$aux_dir1$base.fls\"             >> \"$aux_dir1$base.fls.tmp\"";
  rename "$aux_dir1$base.fls.tmp", "$aux_dir1$base.fls";
  if ($ret) { return $ret; }

  if (-e "$aux_dir1$base.makefile") {
    print "Tikzlatex: Running 'make -f $aux_dir1$base.makefile' ...\n";
    if ($aux_dir) {
      # `latexmk` has set $ENV{TEXINPUTS} in this case
      my $SAVETEXINPUTS = $ENV{TEXINPUTS};
      $ENV{TEXINPUTS} = good_cwd() . $search_path_separator . $ENV{TEXINPUTS};
      pushd($aux_dir);
      $ret = system "make", "-j", "5", "-f", "$base.makefile";
      &popd;
      $ENV{TEXINPUTS} = $SAVETEXINPUTS;
    }
    else {
      $ret = system "make", "-j", "5", "-f", "$base.makefile";
    }
    if ($ret) {
      print
        "Tikzlatex: Error from 'make'\n",
        "The log files for making the figures '$aux_dir1$base-figure*.log'\n",
        "may have information\n";
    }
  }
  else {
    print "Tikzlatex: No '$aux_dir1$base.makefile', so I won't run make.\n";
  }
  return $ret;
}

# vim: ft=perl
