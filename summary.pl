#!/usr/bin/perl

require "./cgiutil.pl";

@seminarfees = (0, 60, 80, 100, 120, 140, 160);
@eventfees = (0, 55, 75, 95, 115, 135);

$teamkumiteeventcost = { TS1 => 90, TK2 => 75 };
$teamkataeventcost = 75;
$dinnercost = 47.50;
$videopasscost = 20;
$adultadmincost = 10;
$kidadmincost = 5;

$seminartotal = 0;
$eventtotal = 0;

headers();

$teamkataevents = 0;
$teamkumiteeventtotal = 0;
$teamkumiteevents = 0;
$teamkataeventtotal = 0;

# Summary of current selections made by the user

my @peoplelist;

foreach (sort { $a->{'name'} cmp $b->{'name'} } @{$session->{"participants"}}) {

  $count = 0;
  $indiv = 0;
#print "<pre>" . Dumper($_) . "</pre>";
  foreach $woof (keys %{$_->{'events'}}) {
    if ($woof =~ /^seminar.$/ and defined $_->{'events'}{$woof}) {
      $count ++;
    }
    if ($woof =~ /^(kata|kobudo|wukf|shobu)$/ and $_->{'events'}{$woof}) {
      $indiv ++;
    }
  }
  $_->{'seminarcount'} = $count;
  $_->{'eventcount'} = $indiv;

  $seminartotal += $seminarfees[$_->{'seminarcount'}];
  $eventtotal += $eventfees[$_->{'eventcount'}];

  my $t = "<li>" . $_->{'name'};

  if ($_->{events}{kata}) {
    $t .= ' - <span style="font-size:16pt;font-face:Arial">Registered for Kata</span>';
    $events ++;
  }
  if ($_->{events}{kobudo}) {
    $t .= ' - <span style="font-size:16pt;font-face:Arial">Registered for Kobudo</span>';
    $events ++;
  }
  if ($_->{events}{shobu}) {
    $t .= ' - <span style="font-size:16pt;font-face:Arial">Registered for Ippon Shobu Kumite</span>';
    $events ++;
  }
  if ($_->{events}{wukf}) {
    $t .= ' - <span style="font-size:16pt;font-face:Arial">Registered for WUKF Kumite</span>';
    $events ++;
  }
  if (defined $_->{events}{seminarA}) {
    $t .= ' - <span style="font-size:16pt;font-face:Arial">Registered for Seminar A</span>';
  }
  if (defined $_->{events}{seminarB}) {
    $t .= ' - <span style="font-size:16pt;font-face:Arial">Registered for Seminar B</span>';
  }
  if (defined $_->{events}{seminarC}) {
    $t .= ' - <span style="font-size:16pt;font-face:Arial">Registered for Seminar C</span>';
  }
  if (defined $_->{events}{seminarD}) {
    $t .= ' - <span style="font-size:16pt;font-face:Arial">Registered for Seminar D</span>';
  }
  if (defined $_->{events}{seminarE}) {
    $t .= ' - <span style="font-size:16pt;font-face:Arial">Registered for Seminar E</span>';
  }
  if (defined $_->{events}{seminarF}) {
    $t .= ' - <span style="font-size:16pt;font-face:Arial">Registered for Seminar F</span>';
  }
  if (defined $_->{events}{seminarG}) {
    $t .= ' - <span style="font-size:16pt;font-face:Arial">Registered for Seminar G</span>';
  }
  $t .= "\n";
  push @peoplelist, $t;
}
# email 2:40 AM 12/4/2012 As far as team events are concerned, you can leave it as it was originally and not list it with the other items at top of the page
#foreach $team (sort keys %{$session->{'teams'}}) {
#	$t = '';
#  if (defined $session->{'teams'}{$team}{katadiv}) {
#    $t .= ' - <span style="font-size:16pt;font-face:Arial">Team '.$team.' Registered for Team Kata</span>';
#  }
#  if (defined $session->{'teams'}{$team}{kumitediv}) {
#		$t .= ' - <span style="font-size:16pt;font-face:Arial">Team '.$team.'Registered for Team Kumite</span>';
#  }
#  $t .= "\n";
#  push @peoplelist, $t;
#}
$peoplelist = "<ul>" . join("", @peoplelist) . "</ul>";

foreach $participant (@{$session->{participants}}) {
  foreach (keys %{$participant->{'events'}}) {
    if (/seminar/) {
      $list{$participant->{'name'}} ++;
    }
    if (/k(ata|umite)/) {
      $list{$participant->{'name'}} ++;
    }
  }
  unless ($list{$participant->{'name'}}) {
    push @warnings, "Warning: Individual $participant->{'name'} is not registered for any contests or seminars.";
  }
}

foreach $team (sort keys %{$session->{'teams'}}) {
  my $TEAM = $session->{'teams'}{$team};
  my $t = "<li>$team";
  if (defined $TEAM->{katadiv}) {
    $t .= " - $TEAM->{katadiv}";
    $teamkataevents ++;
    $teamkataeventtotal += $teamkataeventcost;
  }
  if (defined $TEAM->{kumitediv}) {
    $t .= " - $TEAM->{kumitediv}";
    $teamkumiteevents ++;
    $teamkumiteeventtotal += $teamkumiteeventcost->{$TEAM->{kumitediv}}
  }
  $t .= "\n";
  push @teamlist, $t;
}
$teamlist = "<ul>" . join('', @teamlist) . "</ul>";

$teamkataevents = 0 unless ($teamkataevents);
$teamkumiteevents = 0 unless ($teamkumiteevents);

$session->{'extras'}{'dinners'} = 0 unless (exists $session->{'extras'}{'dinners'});
$dinnertotal = $session->{'extras'}{'dinners'} * $dinnercost;

$session->{'extras'}{'passes'} = 0 unless ($session->{'extras'}{'passes'});
$videopasstotal = $session->{'extras'}{'passes'} * $videopasscost;

$admittotal = $adultadmincost * $session->{'extras'}{'adultsun'};
$admittotal += $adultadmincost * $session->{'extras'}{'adultsat'};
$admittotal += $kidadmincost * $session->{'extras'}{'kidsun'};
$admittotal += $kidadmincost * $session->{'extras'}{'kidsat'};

$grandtotal = $videopasstotal + $dinnertotal + $teamkataeventtotal + $teamkumiteeventtotal + $eventtotal + $admittotal + $seminartotal;

$gtotal = sprintf "%2.2f", $grandtotal;

$session->{'teamkataeventtotal'} = sprintf "%0.2f", $teamkataeventtotal;
$session->{'teamkumiteeventtotal'} = sprintf "%0.2f", $teamkumiteeventtotal;
$session->{'videopasstotal'} = sprintf "%0.2f", $videopasstotal;
$session->{'admittotal'} = sprintf "%0.2f", $admittotal;
$session->{'grandtotal'} = sprintf "%0.2f", $grandtotal;
$session->{'eventtotal'} = sprintf "%0.2f", $eventtotal;
$session->{'seminartotal'} = sprintf "%0.2f", $seminartotal;
$session->{'dinnertotal'} = sprintf "%0.2f", $dinnertotal;

if (scalar @warnings) {
  my $t = "<tr><td colspan=2>";
  foreach (@warnings) {
    $t .= "<p class=instruction>$_</p>";
  }
  $t .= "</td></tr>\n";
  push @warninglist, $t;
}
$warningrow = join "", @warninglist;

if ($grandtotal == 0) {
  push @errors, "You cannot pay because you have not selected anything to buy.";
}

if (!$session->{'dojo'}{'name'} and scalar @{$session->{'participants'}}) {
  push @errors, "Error!  You did not enter your school information!<br>Please Enter School Information to proceed.";
}

foreach (@errors) {
  $t = <<"END";
              <tr>
                <td align="middle" width="100%" bgColor="#ffffff" colSpan="2" height="11">
                  <p style="MARGIN: 4px 0px 2px; LINE-HEIGHT: 100%; color:#F00000; font-family:Arial;"><b>$_</b></p>
                </td>
              </tr>
END
  push @errorlist, $t;
}

if (scalar @errorlist) {
  $errorlist = join "", @errorlist;
} else {
  $errorlist = <<"END";
    <tr>
     <td colspan=2>
      <form action="https://www.paypal.com/cgi-bin/webscr" method="post">
       <input type="hidden" name="cmd" value="_xclick">
       <input type="hidden" name="business" value="jamest\@lvshotokan.com">
       <input type="hidden" name="item_name" value="Ozawa Cup International Karate Tournament Fees">
       <input type="hidden" name="invoice" value="$cookies->{'sessionid'}">
       <input type="hidden" name="amount" value="$gtotal">
       <input type="hidden" name="no_note" value="0">
       <input type="hidden" name="no_shipping" value="1">
       <input type="hidden" name="currency_code" value="USD">
       <input type="hidden" name="notify_url" value="http://www.ozawa-tournament.com/cgi-bin/ipn.pl">
       <input type="image" src="https://www.paypal.com/images/x-click-but23.gif" border="0" name="submit" alt="Make payments with PayPal - it's fast, free and secure!">
       <input type=submit value="Submit Payment for \$$gtotal via Paypal">
      </form>
      <!-- Begin Official PayPal Seal -->
      <A HREF="https://www.paypal.com/verified/pal=jamest%40lvshotokan.com" target="_blank">
       <IMG SRC="http://images.paypal.com/images/verification_seal.gif" BORDER="0" ALT="Official PayPal Seal">
      </A>
      <!-- End Official PayPal Seal -->
     </td>
    </tr>
END
}

#------------------------- PAGE START ---------------------------

print <<"END";
<html>

<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
<meta name="GENERATOR" content="Microsoft FrontPage 4.0">
<meta name="ProgId" content="FrontPage.Editor.Document">
<title>Ozawa Cup Registration</title>
<script language="JavaScript" fptype="dynamicanimation">
<!--
function dynAnimation() {}
function clickSwapImg() {}
//-->
</script>
<script language="JavaScript1.2" fptype="dynamicanimation" src="/animate.js">
</script>
<meta name="Microsoft Border" content="b, default">
</head>

<body onload="dynAnimation()" language="Javascript1.2"><!--msnavigation--><table border="0" cellpadding="0" cellspacing="0" width="100%"><tr><!--msnavigation--><td valign="top">

<p>&nbsp;</p>
<div align="center">
  <center>
  <table height="512" width="88%" border="2">
    <tbody>
      <tr>
        <td vAlign="center" width="100%" bgColor="#c0c0c0" colSpan="2" height="138" align="center">
          <p style="MARGIN-TOP: 0px; MARGIN-BOTTOM: 0px; LINE-HEIGHT: 100%; color:red; font-family:Arial; font-size:4; text-align:center"><b>
          PLEASE FILL OUT THE FOLLOWING REQUIRED INFORMATION BEFORE REGISTERING FOR KATA, KOBUDO, KUMITE &amp; SEMINARS</b></p>
<b><i><span style="font-size:13.5pt;font-family:Arial;color:black">You may register more than one person at a time by clicking on:  </span></i></b></p><p align="center" style="margin-right:0in;margin-bottom:7.5pt;margin-left:0in;text-align:center"><b><span style="font-size:14.0pt;font-family:Arial;color:blue"><a href="http://ozawa-tournament.com/cgi-bin/participant.pl">ENTER INDIVIDUAL INFORMATION</a></span></b><b><span style="font-family:Arial;color:blue"> </span></b></p><p align="center" style="margin-right:0in;margin-bottom:7.5pt;margin-left:0in;text-align:center"><b><i><span style="font-size:12.5pt;font-family:Arial;color:black">.You must enter both Individual and Dojo information to check out.</span></i></b></p>
          <div align="center">
            <center>
            $peoplelist
            <table borderColor="#0000FF" height="23" cellSpacing="0" width="48%" bgColor="#00FFFF" borderColorLight="#0000FF" border="1">
              <tbody>
                <tr>
                  <td width="100%" height="22" align=center>
                    <b><font color="#0000ff" face="Arial"><a href=participant.pl>ENTER INDIVIDUAL INFORMATION</font></b></a>
                  </td>
                </tr>
              </tbody>
            </table>
            &nbsp;<br>
            <table borderColor="#0000FF" height="23" cellSpacing="0" width="48%" bgColor="#00FFFF" borderColorLight="#0000FF" border="1">
              <tbody>
                <tr>
                  <td width="100%" height="21">
                    <p align="center"><b><font color="#0000ff" face="Arial"><a href=dojo.pl>ENTER DOJO INFORMATION</a></font></b></p>
                  </td>
                </tr>
              </tbody>
            </table>
            </center>
          </div>
        </td>
      </tr>
      <tr>
        <td vAlign="center" bgColor="#ffffcc" height="93" align="center">
          <p style="MARGIN-TOP: 0px; MARGIN-BOTTOM: 5px; LINE-HEIGHT: 150%"><b><font color="#ff0000" face="Arial">INDIVIDUAL KATA &amp; KUMITE &amp; KOBUDO</font></b></p>
<center>
          <table height="27" cellSpacing="0" borderColorDark="#0000ff" width="35%" borderColorLight="#0000ff" border="1">
            <tbody>
              <tr>
                <td width="100%" align="center" bgColor="#00ffff" height="23">
                  <p align="center"><b><font color="#0000ff" face="Arial"><a href=event.pl>Register</a></font></b></p>
                </td>
              </tr>
            </tbody>
          </table>
</center>
        </td>
<!--        <td valign="center" width="50%" bgColor="#ffcc66" height="372" rowSpan="4" align="center">
          <table><tr><td height=50p> </td></tr><tr><td>
          <p style="MARGIN-TOP: 0px; MARGIN-BOTTOM: 15px; LINE-HEIGHT: 100%; color:green; font-family:Arial; font-size:larger;"><b>PURCHASE OTHER ITEMS</font></b></p>
          <p style="MARGIN-TOP: 0px; MARGIN-BOTTOM: 2px; LINE-HEIGHT: 100%"><b><font color="#ff0000" face="Arial">SPECTATOR TICKETS&nbsp;</font></b></p>
          <p style="MARGIN-TOP: 0px; MARGIN-BOTTOM: 5px; LINE-HEIGHT: 100%"><b><font color="#ff0000" face="Arial">&amp; SUNDAY'S VIDEO PASS</font></b></p>
          <table height="27" cellSpacing="0" borderColorDark="#0000ff" width="35%" borderColorLight="#0000ff" border="1">
            <tbody>
              <tr>
                <td width="100%" bgColor="#00ffff" height="23">
                  <p align="center"><b><font color="#0000ff" face="Arial"><a href=extras.pl>Purchase</a></font></b></p>
                </td>
              </tr>
            </tbody>
          </table>
          <p style="MARGIN: 30px 0px 5px; font-family:Arial; font-size:larger; color:red;"><b>2014 OZAWA CUP BANQUET</font></b></p>
          <p style="MARGIN: 1px 0px; LINE-HEIGHT: 100%"><b><font color="#008000" face="Arial">Friday - April 6, 2011</font></b></p>
          <p style="MARGIN: 1px 0px 5px; LINE-HEIGHT: 100%"><b><font color="#008000" face="Arial">7:30 - 9:30 PM</font></b></p>
          <table height="27" cellSpacing="0" borderColorDark="#0000ff" width="35%" borderColorLight="#0000ff" border="1">
            <tbody>
              <tr>
                <td width="100%" bgColor="#00ffff" height="23">
                  <p align="center"><b><font color="#0000ff" face="Arial"><a href=extras.pl>Purchase</a></font></b></p>
                </td>
              </tr>
            </tbody>
          </table>
          </td></tr></table>-->
        </td>
      </tr>
      <tr>
        <td vAlign="center" width="50%" bgColor="#ffffcc" height="93" align="center">
          <p style="MARGIN-TOP: 0px; MARGIN-BOTTOM: 5px; LINE-HEIGHT: 150%"><b><font color="#ff0000" face="Arial">TEAM KATA &amp; KUMITE</font></b></p>
          $teamlist
<center>
          <table height="27" cellSpacing="0" borderColorDark="#0000ff" width="35%" borderColorLight="#0000ff" border="1">
            <tbody>
              <tr>
                <td width="100%" align="center" bgColor="#00ffff" height="23">
                  <p align="center"><b><font color="#0000ff" face="Arial"><a href=team.pl>Register</a></font></b></p>
                </td>
              </tr>
            </tbody>
          </table>
</center>
        </td>
      </tr>
      <tr>
        <td vAlign="center" width="50%" align="center" bgColor="#ffffcc" height="93" >
          <p style="MARGIN-TOP: 0px; text-align:center; MARGIN-BOTTOM: 5px; LINE-HEIGHT: 150%"><b><font color="#ff0000" face="Arial">REGISTER FOR SEMINARS</font></b></p>
<center>
          <table height="27" cellSpacing="0" borderColorDark="#0000ff" width="35%" borderColorLight="#0000ff" border="1">
            <tbody>
              <tr>
                <td width="100%" bgColor="#00ffff" align="center" height="23">
                  <p align="center"><b><font color="#0000ff" face="Arial"><a href=event.pl>Register</a></font></b></p>
                </td>
              </tr>
            </tbody>
          </table>
</center>
        </td>
      </tr>
      <tr>
        <td vAlign="center" width="50%" bgColor="#ffffcc" height="93" align="center">
          <p style="MARGIN: 5px 0px 1px; LINE-HEIGHT: 100%"><b><font color="#008000" face="Arial">CLICK
          BELOW TO SEE SEMINARS</font></b></p>
          <p style="MARGIN: 1px 0px 5px; LINE-HEIGHT: 100%"><font face="Arial"><b><font color="#008000">Date,
          Time &amp;</font></b> <font color="#008000"><b>Instructor</b></font></font></p>
<center>
          <table height="27" cellSpacing="0" borderColorDark="#0000ff" width="35%" borderColorLight="#0000ff" border="1">
            <tbody>
              <tr>
                <td width="100%" bgColor="#00ffff" height="23">
                  <p align="center"><b><font color="#0000ff" face="Arial"><a href=/Seminars.htm>See Seminars</a></font></b></p>
                </td>
              </tr>
            </tbody>
          </table>
</center>
        </td>
      </tr>
      <tr>
        <td vAlign="center" width="100%" bgColor="#ffffcc" colSpan="2" height="257" align="center">
         <center>
          <p style="color:green; font-family:Arial; MARGIN: 10px 10px 10px"><b>TOTAL AMOUNT OF ITEMS PURCHASED</b></p>
          <table height="164" cellSpacing="0" width="77%" border="2">
            <tbody>
              <tr>
                <td align="middle" width="93%" bgColor="#c0c0c0" height="19">
                  <p style="MARGIN: 0px; LINE-HEIGHT: 100%"><b><font face="Arial">Individual Kata, Individual Kumite (Ippon & WUKF) and Kobudo</font></b></p>
                </td>
                <td align="middle" width="7%" bgColor="#c0c0c0" height="19"><font face="Arial">\$$eventtotal</font></td>
              </tr>
              <tr>
                <td align="middle" width="93%" bgColor="#ffffff" height="19">
                  <p style="MARGIN: 0px; LINE-HEIGHT: 100%"><b><font face="Arial">Team Kata: $teamkataevents \@ \$75 per event</b></font></p>
                </td>
                <td align="middle" width="7%" bgColor="#ffffff" height="19"><font face="Arial">\$$teamkataeventtotal</font></td>
              </tr>
              <tr>
                <td align="middle" width="93%" bgColor="#ffffff" height="19">
                  <p style="MARGIN: 0px; LINE-HEIGHT: 100%"><b><font face="Arial">Team Kumite:&nbsp; $teamkumiteevents \@ \$90 per event</b></font></p>
                </td>
                <td align="middle" width="7%" bgColor="#ffffff" height="19"><font face="Arial">\$$teamkumiteeventtotal</font></td>
              </tr>
              <tr>
                <td align="middle" width="93%" bgColor="#c0c0c0" height="19">
                  <p style="MARGIN: 0px; LINE-HEIGHT: 100%"><b><font face="Arial">Seminars</font></b></p>
                </td>
                <td align="middle" width="7%" bgColor="#c0c0c0" height="19"><font face="Arial">\$$seminartotal</font></td>
              </tr>
<!--              <tr>
                <td align="middle" width="93%" bgColor="#ffffff" height="3">
                  <p style="MARGIN: 0px; LINE-HEIGHT: 100%"><b><font face="Arial">Spectator Fee</font></b></p>
                </td>
                <td align="middle" width="7%" bgColor="#ffffff" height="3"><font face="Arial">\$$admittotal</font></td>
              </tr>
              <tr>
                <td align="middle" width="93%" bgColor="#c0c0c0" height="19">
                  <p style="MARGIN: 0px; LINE-HEIGHT: 100%"><b><font face="Arial">2014 Ozawa Cup Banquet:&nbsp; $session->{'extras'}{'dinners'} \@ \$47.50 per person</font></b></p>
                </td>
                <td align="middle" width="7%" bgColor="#c0c0c0" height="19"><font face="Arial">\$$dinnertotal</font></td>
              </tr>-->
<!--              <tr>
                <td align="middle" width="93%" bgColor="#ffffff" height="19">
                  <p style="MARGIN: 0px; LINE-HEIGHT: 100%"><b><font face="Arial">Sunday's Video Passes:&nbsp; $session->{'extras'}{'passes'} \@ \$20 each</font></b></p>
                </td>
                <td align="middle" width="7%" bgColor="#ffffff" height="19"><font face="Arial">\$$videopasstotal</font></td>
              </tr>-->
              <tr>
                <td borderColor="#ff0000" align="middle" width="93%" bgColor="#c0c0c0" height="23">
                  <p style="MARGIN: 0px; LINE-HEIGHT: 100%; font-family:Arial; font-weight:bold;">GRAND TOTAL:</p>
                </td>
                <td borderColor="#ff0000" align="middle" width="7%" bgColor="#c0c0c0" height="23"><font face="Arial">\$$grandtotal</font></td>
              </tr>
              $errorlist
            </tbody>
          </table>
         </center>
        </td>
      </tr>
      <tr>
        <td vAlign="center" width="100%" bgColor="#c0c0c0" colSpan="2" height="44" align="center">
          <p style="MARGIN-TOP: 5px; MARGIN-BOTTOM: 5px; WORD-SPACING: 0px; LINE-HEIGHT: 100%; color:blue; font-size:larger; font-family:Arial;"><b>THANK
          YOU FOR REGISTERING IN THE OZAWA CUP INTERNATIONAL KARATE TOURNAMENT</font></b></p>
        </td>
      </tr>
    </tbody>
  </table>
  </center>
</div>

<div align="center">
  <center>
   <b><u><a href="/"><font face="Arial" color="blue">Home</font></a></u></b>
  </center>
</div>

</td></tr><!--msnavigation--></table></body>

</html>
END
