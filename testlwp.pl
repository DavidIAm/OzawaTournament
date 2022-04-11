use LWP::UserAgent;

$ua = LWP::UserAgent->new;                                                                                                                                                 

$headers = HTTP::Headers->new('Content-Type', 'application/x-www-form-urlencoded', 'User-agent', 'LVSHOTOKAN-PAYPAL-IPN');

$request = HTTP::Request->new('POST', "https://ipnpb.paypal.com/cgi-bin/webscr", $headers);

$request->content("TEST");

$response = $ua->request($request);

print $response->as_string;
