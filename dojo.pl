#!/usr/bin/perl

require "./cgiutil.pl";

if (exists $params->{"action"}) {
 
  unless ($params->{'name'}) {
    push @errors, "You must specify the Dojo Name";
  }
  unless ($params->{'sensei'}) {
    push @errors, "You must specify the Sensei's name";
  }
  unless ($params->{'address1'}) {
    push @errors, "You must specify the Dojo's Address";
  }
  unless ($params->{'city'}) {
    push @errors, "You must specify the Dojo's City";
  }
  unless ($params->{'state'}) {
    push @errors, "You must specify the Dojo's State";
  }
  unless ($params->{'postalcode'}) {
    push @errors, "You must specify the Dojo's Postal Code";
  }
  unless ($params->{'country'}) {
    push @errors, "You must specify the Dojo's country";
  }

  unless (scalar @errors) {
    delete $params->{"action"};
    $session->{"dojo"} = $params;
    push @headers, "Location: summary.pl";
    headers();
    exit;
  }
}

if (scalar @errors) {
  $ref = $params;
} else {
  $ref = $session->{'dojo'};
}

headers();

print <<"END";
<center>
<form method=put>
<table border=1>
 <tr>
  <td colspan=2><h2>Enter School Information</h2></td>
END
if (scalar @errors) {
  print "<tr><td colspan=2>";
  foreach (@errors) {
    print "<p class=instruction>$_</p>";
  }
  print "</td></tr>";
}
print <<"END";
 <tr>
  <th>Dojo Name
  <td class=entry><input type=text name=name value="$ref->{name}" size=50>
 </tr>
 <tr>
  <th>Sensei Name
  <td class=entry><input type=text name=sensei size=50 value="$ref->{'sensei'}">
 </tr>
 <tr>
  <th>Phone Number
  <td class=entry><input type=text name=phone size=20 value="$ref->{'phone'}">
 </tr>
 <tr>
  <th>Fax Number
  <td class=entry><input type=text name=fax size=20 value="$ref->{'fax'}">
 </tr>
 <tr>
  <th>Address
  <td class=entry><input type=text name=address1 size=50 value="$ref->{'address1'}">
 </tr>
 <tr>
  <th>Address 2
  <td class=entry><input type=text name=address2 size=50 value="$ref->{'address2'}">
 </tr>
 <tr>
  <th>City
  <td class=entry><input type=text name=city size=40 value="$ref->{'city'}">
 </tr>
 <tr>
  <th>State/Province
  <td class=entry><input type=text name=state size=10 value="$ref->{'state'}">
 </tr>
 <tr>
  <th>Zip/Postal Code
  <td class=entry><input type=text name=postalcode size=10 value="$ref->{'postalcode'}">
 </tr>
 <tr>
  <th>Country
  <td class=entry><input type=text name=country size=40 value="$ref->{'country'}">
 </tr>
 <tr>
  <th>Dojo Email Address
  <td class=entry><input type=text name=email size=40 value="$ref->{'email'}">
 </tr>
 <tr>
  <td colspan=2>
   <input type=submit name=action value="Done">
   <input type=reset value="Start Over">
  </td>
 </tr>
</table>
</form>
</center>
END
