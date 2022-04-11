#!/usr/bin/perl

require "./cgiutil.pl";

if ($params->{'action'} eq "Done") {
  $session->{'extras'}{'adultsun'} = $params->{'adultsun'};
  $session->{'extras'}{'adultsat'} = $params->{'adultsat'};
  $session->{'extras'}{'kidsun'} = $params->{'kidsun'};
  $session->{'extras'}{'kidsat'} = $params->{'kidsat'};
  $session->{'extras'}{'dinners'} = $params->{'dinners'};
  $session->{'extras'}{'passes'} = $params->{'passes'};
  foreach (keys %{$params}) {
    next unless (/^(.+?)(\d+)$/);
    my $n = $1;
    my $i = $2;
    if (length $params->{$_}) {
      $session->{'banquet'}[$i]{$n} = $params->{$_};
    }
  }
  @list = @{$session->{'banquet'}};
  $session->{'banquet'} = [ undef ];
  my $pass;
  my $count = 0;
  foreach (@list) {
    $pass = 1;
    foreach $i (qw/name city state country/) {
      $pass = 0 unless ( exists $_->{$i} );
      $pass = 0 unless ( length $_->{$i} );
    }
    push @{$session->{'banquet'}}, $_ if ($pass);
    $count ++;
    last if ($count > $session->{'extras'}{'dinners'});
  }
  if (scalar(@{$session->{'banquet'}}) == $session->{'extras'}{'dinners'} + 1) {
    push @headers, "Location: summary.pl";
    headers();
    exit;
  } else {
    $guesterror = 1;
  }
}

headers();

print <<"END";
</table>
<form method=post>
<div align=center>
<table border=1>
 <tr>
  <td />
  <th class=topheader>SAT</th>
  <th class=topheader>SUN</th>
 </tr>
 <tr>
  <th class=sideheader>Adult Spectator</th>
  <td>\$10 x <input type=text name=adultsat value="$session->{'extras'}{'adultsat'}" size=3></td>
  <td>\$10 x <input type=text name=adultsun value="$session->{'extras'}{'adultsun'}" size=3></td>
 </tr>
 <tr>
  <th class=sideheader>Kids (5-12)<br>Kids under 5 free</th>
  <td>\$5 x <input type=text name=kidsat value="$session->{'extras'}{'kidsat'}" size=3></td>
  <td>\$5 x <input type=text name=kidsun value="$session->{'extras'}{'kidsun'}" size=3></td>
 </tr>
<!-- <tr>
  <th class=sideheader>Video Pass</th>
  <td>No Charge</td>
  <td>\$20 x <input type=txt name=passes value="$session->{'extras'}{'passes'}" size=3></td>
 </tr>
 <tr>
  <th colspan=3 width=600 class=topheader> 
   <p>2007 Ozawa Cup Banquet: \$45 x <input type=text size=3 name=dinners value="$session->{'extras'}{'dinners'}"></p>

<div style="font-family:Arial; font-size:14pt;">
<span style="color:blue; font-style:italic;">Main Entrées:</span><br>
Broiled Salmon or<br>
Slow roasted prime rib<br>
</div>
-->
<!--   <table border=1 class=topheader>-->
END
#  if ($guesterror) {
#    print "<tr><th colspan=5 class=warning>PLEASE ENTER DATA IN EACH FIELD FOR EACH GUEST</th></tr>\n";
#  }
<<"END";
    <tr> <th colspan=5 class=topheader>Dinner Guests</th> </tr>
    <tr> <th class=topheader>Entree</th><th>Name</th><th>City</th><th>State</th><th>Country</th> </tr>
END
foreach (1..($session->{'extras'}{'dinners'} or 5)) {
	my $salsel = $session->{'banquet'}[$_]{'entree'} eq 'Salmon' ? " CHECKED" : "";
	my $primesel = $session->{'banquet'}[$_]{'entree'} eq 'PrimeRib' ? " CHECKED" : "";
<<"END";
    <tr> 
     <td style=white-space:nowrap>
      <input type=radio name="entree$_" value="Salmon"$salsel>Salmon<br>
      <input type=radio name="entree$_" value="PrimeRib"$primesel>Prime Rib
     </td>
     <td valign=center><input type=text name="name$_" value="$session->{'banquet'}[$_]{'name'}"></td>
     <td valign=center><input type=text name="city$_" value="$session->{'banquet'}[$_]{'city'}"></td>
     <td valign=center><input type=text name="state$_" value="$session->{'banquet'}[$_]{'state'}"></td>
     <td valign=center><input type=text name="country$_" value="$session->{'banquet'}[$_]{'country'}"></td>
    </tr>
END
}
print <<"END";
<!--   </table>-->
  </th>
 </tr>
 <tr>
  <td colspan=3>
   <input type=submit name=action value=Done>
  </td>
 </tr>
</table>
</div>
</form>
END
