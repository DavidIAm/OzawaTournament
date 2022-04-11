#!/usr/bin/perl
#
print <<"END";
Content-type: text/html

<html>
 <head>
  <!-- This script system was developed by David Ihnen <skylos@doglover.com>
       for the Las Vegas Shotokan Dojo <jamest@lvshotokan.com> for the
       Ozawa Cup International Karate Tournament -->
  <title>Ozawa Cup Online Registration</title>
  <style>
    font {
      font-family:Arial,sans-serif;
      color:Black;
    }
    .announce {
      font-family:Times,serif;
      color:Black;
      font-size:x-large;
      text-align:center;
    }
    .button {
      font-family:Helvetica,Arial,sans-serif;
      color:Red;
      text-align:center;
      text-transform:upcase;
      font-size:Medium;
      width:200;
    }
    a:link {
      color:Red;
      text-decoration:none;
    }
    a:visited {
      color:Red;
      text-decoration:none;
    }
    a:active {
      color:Red;
      text-decoration:none;
    }
    .instruction {
      color:Red;
      font-size:Medium;
    }
    .sectionheaderlight {
      font-family:Arial,sans-serif;
      font-size:Large;
      text-transform:uppercase;
      color:#0093DD;
      display-as: block;
    }
    .sectionheaderdark {
      font-family:Arial,sans-serif;
      font-size:Large;
      text-transform:uppercase;
      color:white;
      display-as: block;
    }
    table {
      border-color:Black;
    }
    td {
      vertical-align:top;
      text-align:center;
    }
    .totals {
      font-size:Medium;
    }
    .topheader {
      background-color:#BBBBBB;
      font-size:Medium;
    }
    .sideheader {
      text-align=right;
      background-color:#BBBBBB;
      font-size:Medium;
    }
    .entry {
      text-align:left;
    }
    .dark {
      background-color:#0093DD;
    }
    .light {
      bgcolor:white;
    }
    ul {
      color:black;
      font-size:large;
      text-align:left;
    }
  </style>
 </head>
 <body bgcolor="white">
  <p align=center>
   <img src="../images/TournamentTitle.jpg" alt="The Ozawa Cup Karate Tournament">
  </p>
  <div class=announce>Tournament & Seminar Registration</div>
  <table width="100%" border="1" cellspacing="0">
   <tr>
    <td>
      <h1>Your payment has been received.  Thank you for attending the Ozawa Cup International Karate Tournament!</h1>
    </td>
   </tr>
  </table>
 </body>
</html>
END
