#!/usr/bin/perl

require "./cgiutil.pl";

if (exists $params->{"action"}) {
  if ($params->{'action'} eq "Abort and go Back to Summary") {
    push @headers, "Location: summary.pl";
    headers();
    exit;
  }

  if ($params->{'action'} eq "Delete Individual") {
    splice @{$session->{'participants'}}, $params->{'participant'}, 1;
    push @headers, "Location: participant.pl";
    headers();
    exit;
  }

  if ($params->{'action'} eq "I Agree") {

    # Error checking.
    unless ($params->{'name'}) {
      push @errors, "You must enter a name";
    }
    unless ($params->{'rank'} ne "choose") {
      push @errors, "You must choose a rank";
    }
#    unless ($params->{'training'}) {
#      push @errors, "You must enter how many years you have been training";
#    }
    if ( 4 != length $params->{'dob-year'}) {
      push @errors, "You must enter the full four digit year you were born";
    }
#    if ($params->{'rank'} eq "Black Belt" and 
#        $params->{'dob-year'} < 1986 and
#        $params->{'dob-year'} > 1969) {
#      unless ($params->{'weight'}) {
#        push @errors, "You must enter your weight for division determination";
#      }
#    }
    unless ($params->{'gender'}) {
      push @errors, "You must enter a gender";
    }
    unless ($params->{'dob-month'} ne "-") {
      push @errors, "You must enter your date of birth (month)";
    }
    unless ($params->{'dob-day'} ne "-") {
      push @errors, "You must enter your date of birth (day)";
    }
    unless ($params->{'dob-year'}) {
      push @errors, "You must enter your date of birth (year)";
    }
    unless ($params->{'address1'}) {
      push @errors, "You must enter at least the first line of an address";
    }
    unless ($params->{'city'}) {
      push @errors, "You must enter your city";
    }
    unless ($params->{'state'}) {
      push @errors, "You must enter your state or province";
    }
    unless ($params->{'postalcode'}) {
      push @errors, "You must enter your postal code";
    }
    unless ($params->{'country'}) {
      push @errors, "You must enter your country";
    }
    unless ($params->{'email'}) {
      push @errors, "You must enter your email";
    }

    # time to handle the form
    $ref = {};
    foreach (keys %{$params}) {
      $ref->{$_} = $params->{$_};
    }

    # If there are no errors we save the data and toss it back to summary
    unless (scalar @errors) {
      if (exists $params->{'participant'}) {
        $session->{'participants'}[$params->{'participant'}] = $ref;
      } else {
        push @{$session->{"participants"}}, $ref;
      }
      push @headers, "Location: summary.pl";
      headers();
      exit;
    }
  }
}

headers();

if ($params->{'participant'} eq 'new') {
  delete $params->{'participant'};
}

if (scalar @{$session->{participants}}) {
  print qq^<form name=selector>
    <select name=participant onChange="selector.submit()">
     <option value=new>New Individual</option>\n^;
  $count = 0;
  foreach (@{$session->{participants}}) {
    print qq^<option value="$count"^;
    print " SELECTED" if (exists $params->{'participant'} and $count == $params->{'participant'});
    print qq^>$_->{"name"}</option>\n^;
  } continue {
    $count ++;
  }
  print qq^</select><br><input type=submit value="Edit Individual"><br>\n^;
  print qq^<input type=submit name=action value="Delete Individual"></form>\n^;
}

$message = "Add New Individual";

if (exists $params->{'participant'}) {
  $ref = $session->{'participants'}[$params->{'participant'}];
  $message = "Edit existing Individual";
  $partpass = "<input type=hidden name=participant value=$params->{'participant'}>";
}

$gendermaleradio = " CHECKED" if ($ref->{'gender'} eq "Male");
$genderfemaleradio = " CHECKED" if ($ref->{'gender'} eq "Female");

print <<"END";
<form method=post>
$partpass
<table border=1>
 <tr><td colspan=2 align=center><h2>$message</h2></td></tr>
END
if (scalar @errors) {
  print "<tr><td colspan=2>";
  foreach (@errors) {
    print "<p class=instruction>$_</p>\n";
  }
  print "</td></tr>";
}
print <<"END";
 <tr>
  <th>Individual's Name</th>
  <td class=entry><input type=text name=name size=50 value="$ref->{'name'}"></td>
 </tr>
 <tr> 
  <th>Rank</th>
  <td class=entry>
   <select name=rank>
END
  @ranks = ("choose", "Beginner", "Intermediate", "Advanced", "Black Belt" );
  %ranks = (
    "choose" => "Choose your rank",
    "Beginner" => "Beginner: 7th Kyu & under",
    "Intermediate" => "Intermediate: 6th, 5th and 4th Kyu",
    "Advanced" => "Brown Belt: 3rd, 2nd, and 1st Kyu",
    "Black Belt" => "Black Belt",
  );
#  @ranks = ("choose", "Beginner: 7th Kyu and Under", "Intermediate: 6th, 5th, and 4th Kyu", "Brown Belt: 3rd, 2nd, and 1st Kyu", "Black Belt 1", "Black Belt 2", "Senior 1", "Senior 2" );
#  %ranks = (
#    "choose" => "your rank",
#    "Beginner" => "Less than 1 year of training or 7th Kyu & under",
#    "Intermediate" => "More than 1 year of training or 6th, 5th and 4th Kyu",
#    "Advanced" => "Brown Belt - 3rd, 2nd, and 1st Kyu",
#    "Black Belt 1" => "17 years and below",
#    "Black Belt 2" => "18 years and up",
#    "Senior 1" => "Advanced & Black Belt only - 35 to 44 years of age",
#    "Senior 2" => "Advanced & Black Belt only - 45 years old & over",
#  );
  foreach (@ranks) {
    print "<option value=\"$_\"";
    if ($ref->{'rank'} eq $_) {
      print " SELECTED";
    }
    print ">$ranks{$_}</option>";
  }
  print <<"END";
   </select>
  </td>
 </tr>
<!-- <tr>
  <th>Years of Training</th>
  <td class=entry><input type=text name=training size=5 value="$ref->{'training'}"></td>
 </tr>-->
 <tr>
  <th>Date Of Birth</th>
  <td class=entry>
   Month <select name="dob-month">
    <option value="-">Select</option>
END
    foreach (1..12) {
     print qq| <option value="$_"|;
     print " SELECTED" if ($ref->{'dob-month'} eq $_);
     print qq|>$_</option>\n|;
   }
print <<"END";
   </select>
   Day <select name="dob-day">
    <option value="-">Select</option>
END
    foreach (1..31) {
     print qq| <option value="$_"|;
     print " SELECTED" if ($ref->{'dob-day'} == $_);
     print qq|>$_</option>\n|;
    }
print <<"END";
   </select>
   Year <input type=text size=4 maxlength=4 name=dob-year value="$ref->{'dob-year'}">
  </td>
 </tr>
<!-- <tr>
  <th>Weight if black belt 18-34 years old competing in kumite</th>
  <td class=entry><input type=text name=weight size=5 value="$ref->{'weight'}"></td>
 </tr>-->
 <tr>
  <th>Gender</th>
  <td class=entry>
   <table>
    <tr><td class=entry><input type=radio name=gender value=Male$gendermaleradio> Male</td></tr>
    <tr><td class=entry><input type=radio name=gender value=Female$genderfemaleradio> Female</td></tr>
   </table>
  </td>
 </tr>
 <tr>
  <th>Address 1</th>
  <td class=entry><input type=text name=address1 size=50 value="$ref->{'address1'}"></td>
 </tr>
 <tr>
  <th>Address 2</th>
  <td class=entry><input type=text name=address2 size=50 value="$ref->{'address2'}"></td>
 </tr>
 <tr>
  <th>City</th>
  <td class=entry><input type=text name=city size=50 value="$ref->{'city'}"></td>
 </tr>
 <tr>
  <th>State/Province</th>
  <td class=entry><input type=text name=state size=25 value="$ref->{'state'}"></td>
 </tr>
 <tr>
  <th>Zip/Postal Code</th>
  <td class=entry><input type=text name=postalcode size=12 value="$ref->{'postalcode'}"></td>
 </tr>
 <tr>
  <th>Country</th>
  <td class=entry><input type=text name=country size=50 value="$ref->{'country'}"></td>
 </tr>
 <tr>
  <th>E-Mail Address</th>
  <td class=entry><input type=text name=email size=50 value="$ref->{'email'}"></td>
 </tr>
 <tr>
  <td  colspan=2><blockquote>I, the entrant, hereby submit my application for participation in the Ozawa Cup International Karate Tournament.  I hereby acknowledge that there are possible risks of bodily injuries involved in competing in the Tournament.  I hereby waive and release any and all claims, causes of action, losses, damages, cost expenses including but not limited to attourney fees, either known or unknown, now existing or arise in the future, that may have of whatever kind or nature against any Tournament organizer, director or anyone else involved in any way with the Tournament.  I hereby acknowledge that any individual, team, or other pictures listed in connection with the Tournament can be used by the Tournament organizer for publicity or promotion without compensation to me.</blockquote></td>
 <tr>
  <th colspan=2>
   <input type=submit name=action value="I Agree">
   <input type=reset value="Clear Fields">
   <input type=submit name=action value="Abort and go Back to Summary">
  </th>
 </tr>
</table>
</form>

END

