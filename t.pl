open FILE, "sessions/1099012812.dat";

foreach (<FILE>) {
	$dat .= $_;
}
$data = eval $dat;

  if ($data->{'extras'}{'dinners'}) {
    print("\n2004 Ozawa Cup Banquets: $data->{'extras'}{'dinners'}\n");
    print("Banquet Attendees:\n");
    print(sprintf "%10s|%20s|%20s|%20s|%20s\n", 'Entree', 'Name', 'City', 'State', 'Country');
    print(sprintf "%10s|%20s|%20s|%20s|%20s\n", "-"x10, "-"x20, "-"x20, "-"x20, "-"x20);
    foreach (@{$data->{'banquet'}}) {
      next unless (defined $_);
      next unless (exists $_->{'name'});
      print(sprintf "%10s|%20s|%20s|%20s|%20s", $_->{'entree'}, $_->{'name'}, $_->{'city'}, $_->{'state'}, $_->{'country'});
    }
    print("\n");
  }
  
