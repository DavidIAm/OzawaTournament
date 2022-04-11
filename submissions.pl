#!/usr/bin/perl

my $value;

print "Content-type: text/html\n\n";

open FILE, "SAFETY_LOG" or die "Failed to open!!";
while (<FILE>) {
  if ($value and /^\$VAR/) {
    push @notifies, eval $value;;
    $value = '';
  }
  $value .= $_;
}
close FILE;
push @notifies, eval $value;;

foreach $v (@notifies) {
  print qq/<form method=post action="ipn.pl">\n/;
  foreach (keys %{$v}) {
    if ($v eq 'payment_date') { print qq/$v->{$_}/ };
    print qq/<input type=hidden name="$_" value="$v->{$_}">\n/;
  }
  print qq/<input type=submit value="Submit Cart"> $v->{'mc_gross'} on $v->{'payment_date'} version $v->{notify_version}\n/;
  print qq^</form>\n^;
}

