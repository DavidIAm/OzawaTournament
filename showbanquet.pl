#!/usr/bin/perl

print "Content-type: text/html\n\n";

use IO::Dir;

my $dir = new IO::Dir "sessions";

print <<"END";
<table border=1>
<tr>
 <th>name</th>
 <th>city</th>
 <th>state</th>
 <th>country</th>
</tr>
END

while ($_ = $dir->read()) {
  next unless (-f "sessions/$_");
  undef $this;
  $this = do "./sessions/$_";
  next unless (exists $this->{banquet});
  next unless (exists $this->{paypal} and $this->{paypal}{payment_status} eq 'Completed');
  foreach (@{$this->{banquet}}) {
    next unless (defined $_);
    next unless (exists $_->{'name'});
    print <<"END";
<tr>
<td>$_->{name}</td>
<td>$_->{city}</td>
<td>$_->{state}</td>
<td>$_->{country}</td>
</tr>
END
  }

}

print "</table>";
