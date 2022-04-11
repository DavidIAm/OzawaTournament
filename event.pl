#!/usr/bin/perl

require "./cgiutil.pl";

if ($params->{'action'} eq "Done") {
  my $count = 0;
  foreach (@{$session->{'participants'}}) {
    foreach (qw/kata kobudo shobu wukf seminarA seminarB seminarC seminarD seminarE seminarF seminarG/) {
      if (exists $params->{$_ . $count}) {
        $session->{'participants'}[$count]{'events'}{$_} = $params->{$_.$count};
      } else {
        delete $session->{'participants'}[$count]{'events'}{$_};
      }
    }
  } continue {
    $count ++;
  }
  push @headers, "Location: summary.pl";
  headers();
  exit;
}

headers();

unless (scalar @{$session->{'participants'}}) {
  print <<"END";
 <tr>
  <td colspan=9>
   <font size=+2>You can't register for individual events until you enter the participants.  Please proceed to the <a href=participant.pl>Participant Entry Page</a></font>
  </td>
 </tr>
END
} else {

  print <<"END";
 <form method=POST>
 <tr>
  <td colspan=11>
   <h1>Individual Registration<br>Competition and Seminars</h1>
  </td>
 </tr>
 <tr>
  <th rowspan=2>Individual</th>
  <th colspan=2 rowspan=2>Events</th>
  <th colspan=7>Seminars</th>
 </tr>
 <tr>
  <th>A</th>
  <th>B</th>
  <th>C</th>
  <th>D</th>
  <th>E</th>
  <th>F</th>
  <th>G</th>
 </tr>
END

$count = 0;
my $divisions = 
  { kata => 
    [ { value => 'KK', label => '6 & under beginner, male and female kata' }
    , { value => 'K3', label => '7 years old beginner, male and female kata' }
    , { value => 'K4', label => '7 & under intermediate, male and female kata' }
    , { value => 'K5', label => '7 & under advance, male and female kata' }
    , { value => 'K6', label => '8 & 9 beginner, female kata' }
    , { value => 'K7', label => '8 & 9 beginner, male kata' }
    , { value => 'K8', label => '8 & 9 intermediate, female kata' }
    , { value => 'K9', label => '8 & 9 intermediate, male kata' }
    , { value => 'K10', label => '8 & 9 advance, female kata' }
    , { value => 'K11', label => '8 & 9 advance, male kata' }
    , { value => 'K12', label => '10, 11, & 12 beginner, female kata' }
    , { value => 'K13', label => '10, 11, & 12 beginner, male kata' }
    , { value => 'K14', label => '10, 11, & 12 intermediate, female kata' }
    , { value => 'K15', label => '10, 11, & 12 intermediate, male kata' }
    , { value => 'K16', label => '10, 11, & 12 brown belt, female kata' }
    , { value => 'K17', label => '10, 11, & 12 brown belt, male kata' }
    , { value => 'K18', label => '10, 11, & 12 black belt, female kata'  }
    , { value => 'K19', label => '10, 11, & 12 black belt, male kata'  }
    , { value => 'K20', label => '13 & 14 beginner, female kata' }
    , { value => 'K21', label => '13 & 14 beginner, male kata' }
    , { value => 'K22', label => '13 & 14 intermediate, female kata' }
    , { value => 'K23', label => '13 & 14 intermediate, male kata' }
    , { value => 'K24', label => '13 & 14 brown belt, female kata' }
    , { value => 'K25', label => '13 & 14 brown belt, male kata' }
    , { value => 'K26', label => '13 & 14 black belt, female kata'  }
    , { value => 'K27', label => '13 & 14 black belt, male kata'  }
    , { value => 'K28', label => '15, 16, & 17 beginner, female kata' }
    , { value => 'K29', label => '15, 16, & 17 beginner, male kata' }
    , { value => 'K30', label => '15, 16, & 17 intermediate, female kata' }
    , { value => 'K31', label => '15, 16, & 17 intermediate, male kata' }
    , { value => 'K32', label => '15, 16, & 17 brown belt, female kata' }
    , { value => 'K33', label => '15, 16, & 17 brown belt, male kata' }
    , { value => 'K34', label => '15, 16, & 17 black belt, female kata' }
    , { value => 'K35', label => '15, 16, & 17 black belt, male kata' }
    , { value => 'K36', label => '18 & over adult beginner, female kata' }
    , { value => 'K37', label => '18 & over adult beginner, male kata' }
    , { value => 'K38', label => '18 & over adult intermediate, female kata' }
    , { value => 'K39', label => '18 & over adult intermediate, male kata' }
    , { value => 'K40', label => '18 & over adult brown belt, female kata' }
    , { value => 'K41', label => '18 & over adult brown belt, male kata' }
    , { value => 'K1', label => '18-34 adult black belt, female kata' }
    , { value => 'K2', label => '18-34 adult black belt, male kata' }
    , { value => 'K42', label => '35-45, adult black belt female kata' }
    , { value => 'K43', label => '35-45, adult black belt male kata' }
    , { value => 'K44', label => '46-59, adult black belt female kata' }
    , { value => 'K45', label => '46-59, adult black belt male kata' }
    , { value => 'K46', label => '60 & over adult black belt female kata' }
    , { value => 'K47', label => '60 & over adult black belt male kata' }
    ]
  , kobudo =>
    [ { value => 'W0', label => '8-14 beginner & intermediate, female and male' }
    , { value => 'W1', label => '9 & under advance, male and female' }
    , { value => 'W2', label => '10-12 advance, male and female' }
    , { value => 'W3', label => '13-14 advance, female'  }
    , { value => 'W4', label => '13-14 advance, male'  }
    , { value => 'W5', label => '15-17 advance, female'  }
    , { value => 'W6', label => '15-17 advance, male'  }
    , { value => 'W7', label => '18 & over black belt, female'  }
    , { value => 'W8', label => '18 & over black belt, male'  }
    ]
  , shobu =>
    [ { value => 'SS', label => '6 & under beginner, male and female Kumite' }
    , { value => 'S3', label => '7 years old beginner, male and female Kumite' }
    , { value => 'S4', label => '7 & under intermediate, male and female Kumite' }
    , { value => 'S5', label => '7 & under advance, male and female Kumite' }
    , { value => 'S6', label => '8 & 9 beginner, female Kumite' }
    , { value => 'S7', label => '8 & 9 beginner, male Kumite' }
    , { value => 'S8', label => '8 & 9 intermediate, female Kumite' }
    , { value => 'S9', label => '8 & 9 intermediate, male Kumite' }
    , { value => 'S10', label => '8 & 9 advance, female Kumite' }
    , { value => 'S11', label => '8 & 9 advance, male Kumite' }
    , { value => 'S12', label => '10, 11, & 12 beginner, female Kumite' }
    , { value => 'S13', label => '10, 11, & 12 beginner, male Kumite' }
    , { value => 'S14', label => '10, 11, & 12 intermediate, female Kumite' }
    , { value => 'S15', label => '10, 11, & 12 intermediate, male Kumite' }
    , { value => 'S16', label => '10, 11, & 12 brown belt, female Kumite' }
    , { value => 'S17', label => '10, 11, & 12 brown belt, male Kumite' }
    , { value => 'S18', label => '10, 11, & 12 black belt, female Kumite'  }
    , { value => 'S19', label => '10, 11, & 12 black belt, male Kumite'  }
    , { value => 'S20', label => '13 & 14 beginner, female Kumite' }
    , { value => 'S21', label => '13 & 14 beginner, male Kumite' }
    , { value => 'S22', label => '13 & 14 intermediate, female Kumite' }
    , { value => 'S23', label => '13 & 14 intermediate, male Kumite' }
    , { value => 'S24', label => '13 & 14 brown belt, female Kumite' }
    , { value => 'S25', label => '13 & 14 brown belt, male Kumite' }
    , { value => 'S26', label => '13 & 14 black belt, female Kumite'  }
    , { value => 'S27', label => '13 & 14 black belt, male Kumite'  }
    , { value => 'S28', label => '15, 16, & 17 beginner, female Kumite' }
    , { value => 'S29', label => '15, 16, & 17 beginner, male Kumite' }
    , { value => 'S30', label => '15, 16, & 17 intermediate, female Kumite' }
    , { value => 'S31', label => '15, 16, & 17 intermediate, male Kumite' }
    , { value => 'S32', label => '15, 16, & 17 brown belt, female Kumite' }
    , { value => 'S33', label => '15, 16, & 17 brown belt, male Kumite' }
    , { value => 'S34', label => '15, 16, & 17 black belt, female Kumite' }
    , { value => 'S35', label => '15, 16, & 17 black belt, male Kumite' }
    , { value => 'S36', label => '18 & over adult beginner, female Kumite' }
    , { value => 'S37', label => '18 & over adult beginner, male Kumite' }
    , { value => 'S38', label => '18 & over adult intermediate, female Kumite' }
    , { value => 'S39', label => '18 & over adult intermediate, male Kumite' }
    , { value => 'S40', label => '18 & over adult brown belt, female Kumite' }
    , { value => 'S41', label => '18 & over adult brown belt, male Kumite' }
    , { value => 'S1', label => '18-34 women\'s black belt Kumite' }
    , { value => 'S2', label => '18-34 men\'s black belt Kumite' }
    , { value => 'S42', label => '35-45, adult black belt female Kumite' }
    , { value => 'S43', label => '35-45, adult black belt male Kumite' }
    , { value => 'S44', label => '46-59 adult black black belt female Kumite' }
    , { value => 'S45', label => '46-59 adult black black belt male Kumite' }
    , { value => 'S46', label => '60 & over adult black belt female Kumite' }
    , { value => 'S47', label => '60 & over adult black belt male Kumite' }
    ]
  , wukf =>
    [ { value => 'WUKF1', label => '13-14 black belt, female' }
    , { value => 'WUKF2', label => '13-14 black belt, male' }
    , { value => 'WUKF3', label => '15-17 black belt, female' }
    , { value => 'WUKF4', label => '15-17 black belt, male' }
    , { value => 'WUKF5', label => '18-34 black belt, women\'s open weight' }
    , { value => 'WUKF6', label => '18-34 black belt, men\'s open weight' }
    ]
  };
foreach $p (@{$session->{'participants'}}) {

  $kataoptions =   join '', map { '<option value="' . $_->{value} . '"' . ($p->{'events'}{'kata'}   eq $_->{value} ? ' selected' : '') . '>' . ($_->{footnote} ? '*'x$_->{footnote}.' ' : '') . $_->{value} . ": " . $_->{label} . "</option>" } @{$divisions->{kata}};
  $kobudooptions = join '', map { '<option value="' . $_->{value} . '"' . ($p->{'events'}{'kobudo'} eq $_->{value} ? ' selected' : '') . '>' . ($_->{footnote} ? '*'x$_->{footnote}.' ' : '') . $_->{value} . ": " . $_->{label} . "</option>" } @{$divisions->{kobudo}};
  $shobuoptions =  join '', map { '<option value="' . $_->{value} . '"' . ($p->{'events'}{'shobu'}  eq $_->{value} ? ' selected' : '') . '>' . ($_->{footnote} ? '*'x$_->{footnote}.' ' : '') . $_->{value} . ": " . $_->{label} . "</option>" } @{$divisions->{shobu}};
  $wukfoptions =    join '', map { '<option value="' . $_->{value} . '"' . ($p->{'events'}{'wukf'}    eq $_->{value} ? ' selected' : '') . '>' . ($_->{footnote} ? '*'x$_->{footnote}.' ' : '') . $_->{value} . ": " . $_->{label} . "</option>" } @{$divisions->{wukf}};
  $Acheck = exists $p->{'events'}{'seminarA'} ? " CHECKED" : undef;
  $Bcheck = exists $p->{'events'}{'seminarB'} ? " CHECKED" : undef;
  $Ccheck = exists $p->{'events'}{'seminarC'} ? " CHECKED" : undef;
  $Dcheck = exists $p->{'events'}{'seminarD'} ? " CHECKED" : undef;
  $Echeck = exists $p->{'events'}{'seminarE'} ? " CHECKED" : undef;
  $Fcheck = exists $p->{'events'}{'seminarF'} ? " CHECKED" : undef;
  $Gcheck = exists $p->{'events'}{'seminarG'} ? " CHECKED" : undef;

  print <<"END";
 <tr>
  <th rowspan=4>$p->{'name'}</th>
  <th>Individual Kata</th>
  <td><select name=kata$count><option value="">- no entry -</option>$kataoptions</select></td>
  <td><input type=checkbox name=seminarA$count value=$count $Acheck></td>
  <td><input type=checkbox name=seminarB$count value=$count $Bcheck></td>
  <td><input type=checkbox name=seminarC$count value=$count $Ccheck></td>
  <td><input type=checkbox name=seminarD$count value=$count $Dcheck></td>
  <td><input type=checkbox name=seminarE$count value=$count $Echeck></td>
  <td><input type=checkbox name=seminarF$count value=$count $Fcheck></td>
  <td><input type=checkbox name=seminarG$count value=$count $Gcheck></td>
 </tr> 
 <tr>
  <th>Kobudo</span></th>
  <td><select name=kobudo$count><option value="">- no entry -</option>$kobudooptions</select></td>
 <tr>
  <th>Individual Ippon Shobu Kumite</th>
  <td><select name=shobu$count><option value="">- no entry -</option>$shobuoptions</select></td>
 <tr>
  <th>Individual WUKF Kumite<br><span style="font-size:-1">Black Belts Only</span></th>
  <td><select name=wukf$count><option value="">- no entry -</option>$wukfoptions</select></td>
 <tr>
 </tr>
END
} continue {
  $count ++;
}
print <<"END";
 <tr>
  <td colspan=11>
   <input type=submit name=action value="Done">
   <input type=reset value="Start Over">
  </td>
 </tr>
</table>
END

<<"END";
   <input type=checkbox name=seminarA value=register$Acheck> A - James Tawatao<br>
   <input type=checkbox name=seminarB value=register$Bcheck> B - Tomohiro Arashiro<br>
   <input type=checkbox name=seminarC value=register$Ccheck> C - James Tawatao<br>
   <input type=checkbox name=seminarD value=register$Dcheck> D - Fritz Nopel<br>
   <input type=checkbox name=seminarE value=register$Echeck> E - Yukiyoshi Marutani<br>
   <input type=checkbox name=seminarF value=register$Fcheck> F - James Tawatao<br>
   <input type=checkbox name=seminarG value=register$Gcheck> G - Tomohiro Arashiro<br>
 
 </tr>
</table>
END

}
