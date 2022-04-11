#!/usr/bin/perl

require ("./cgiutil.pl");

if (exists $params->{"action"}) {
  if ($params->{"action"} eq "Remove from Team") {
    @{$session->{'teams'}{$params->{"team"}}{"members"}} = map { $_ eq $params->{'name'} ? () : $_ } @{$session->{'teams'}{$params->{"team"}}{"members"}};
    delete $session->{'teams'}{$params->{"team"}} unless (2 <scalar @{$session->{'teams'}{$params->{"team"}}});
  } elsif ($params->{"action"} eq "Delete Team") {
    delete $session->{'teams'}{$params->{"team"}};
  } elsif ($params->{"action"} eq "Add This Team") {

    # Error checking - all three members real values plus entry into a contest
    if ($params->{'member0'} 
               and
        $params->{'member1'}
               and
        $params->{'member2'}
               and
        ($params->{'katadiv'} ne "---" or $params->{'kumitediv'} ne "---")
	   ) {
      
      @{$session->{'teams'}{$params->{"team"}}{"members"}} = ();
      foreach (0..2) {
        if (exists $params->{"member" . $_} and $params->{"member" . $_}) {
          push @{$session->{'teams'}{$params->{"team"}}{"members"}}, $params->{"member" . $_};
        }
      }
      $session->{'teams'}{$params->{"team"}}{"katadiv"} = $params->{katadiv} unless ($params->{katadiv} eq "---");
      $session->{'teams'}{$params->{"team"}}{"kumitediv"} = $params->{kumitediv} unless ($params->{kumitediv} eq "---");

    } else {

      if ($params->{'katadiv'} eq "---" and $params->{'kumitediv'} eq "---") {
        push @message, "<p class=instruction>Error!  You forgot to enter a contest!  Press your browser's back button to retrieve your entries.</p>";
      }

      unless ($params->{'member0'} and $params->{'member1'} and $params->{'member2'}) {
        push @message, "<p class=instruction>Error!  Teams must have three members!  Press your browser's back button to retrieve your entries.</p>";
      }

      if (exists $session->{'teams'}{$params->{'name'}}) {
        push @message, "<p class=instruction>Error!  The name you specified is already used by you!  It must be unique.  Press your browser's back button to retrieve your entries.</p>";
      }

    }
  } elsif ($params->{"action"} eq "Done") {
    push @headers, "Location: summary.pl";
    headers();
    exit;
  }
}

headers();

print <<"END";
<html>
<title>Team Management Form</title>
<body>
<h1 align=center>Team Management</h1>
<h2>Existing Teams</h2>
<ul>
END

foreach $team (sort keys %{$session->{"teams"}}) {
  print "<li>$team ";
  print "(kumite)" if ($session->{'teams'}{$team}{'kumitediv'});
  print "(kata)" if ($session->{'teams'}{$team}{'katadiv'});
  print " - <a href=team.pl?team=" . cgiencode($team) . "&action=Delete+Team>Delete Team</a><ol>";
  foreach (@{$session->{"teams"}{$team}{"members"}}) {
    print "<li>" . $_ . "</li>";
  }
  print "</ol>";
}

unless ($teamnum = scalar keys %{$session->{"teams"}}) {
  print "<li>No teams defined</li>\n";
}

while (exists $session->{'teams'}{"Team " . $teamnum}) {
  $teamnum ++;
}

print <<"END";
</ul>
<table border=1>
 <tr>
  <td colspan=2><h2>New Team</h2>
   <form method=post>
  </td>
 </tr>
END
if (scalar @message) {
  print "<tr><td colspan=2>\n"; 
  foreach (@message) { print "$_\n"; }
  print "</td></tr>\n";
}
print <<"END";
 <tr>
  <th>Team Name</th>
  <td class=entry><input type=text name=team size=50></td>
 </tr>
 <tr>
  <th>Name of First Team Member</th>
  <td class=entry><input type=text name=member0 size=50>
 </tr>
 <tr>
  <th>Name of Second Team Member</th>
  <td class=entry><input type=text name=member1 size=50>
 </tr>
 <tr>
  <th>Name of Third Team Member</th>
  <td class=entry><input type=text name=member2 size=50>
 </tr>
 <tr>
  <th>Team Kata Division</th>
  <td class=entry><select name=katadiv>
END
%teamkatadiv = (
  "---" => { name => "Choose Your Team Kata Division" },
  "TK1" => { name => "14 & under Team Kata - all belts" },
  "TK2" => { name => "15 & over Team Kata - black belt only" },
);

print "<option value='---'>Choose your Team Kata Division</option>";
foreach (qw/TK1 TK2/) {
  print "<option value=$_>";
  print('*'x$teamkatadiv{$_}{footnote});
  print "$_: $teamkatadiv{$_}{name}</option>\n";
}

print <<"END";
   </select>
  </td>
 </tr>
 <tr>
  <th>Team Kumite Division</th>
  <td class=entry>
   <select name=kumitediv>
END
%teamkumitediv = (
  "TS1" => { name => "15-17 Male Black Belt Team Rotation Kumite" },
);

print "<option value='---'>Choose your Team Kumite Division</option>\n";
foreach (keys %teamkumitediv) {
  print "<option value=\"$_\">";
  print '*'x$teamkumitediv{$_}{footnote};
  print "$_: $teamkumitediv{$_}{name}</option>\n";
}

print <<"END";
   </select>
  </td>
 </tr>
 <tr>
  <td colspan=2>
We hereby submit our application for participation in the Ozawa Cup karate tournament.  We hereby acknowledge that there are possible risks of bodily injuries involved in competing in the Tournament.  We hereby waive and release any and all claims, causes of action, losses, damages, cost expenses including but not limited to attourney fees, either known or unknown, now existing or arise in the future, that may have of whatever kind or nature against any Tournament organizer, director or anyone else involved in any way with the Tournament.  We hereby acknowledge that any individual, team, or any other pictures listed in connection with the Tournament can be used by the Tournament organizer for publicity or promotion without compensation to any individual member of the team or the team as a whole.
  </td>
 </tr>
 <tr>
  <td colspan=2>
   <input type=submit name=action value="Add This Team">
   <input type=submit name=reset value="Start Over">
   <input type=submit name=action value="Done">
  </td>
 </tr>
</table>
</table>
</body>
</html>
END

