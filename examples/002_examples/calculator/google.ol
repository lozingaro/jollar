// https://www.google.it/search?q=sistemi+operativi

// https://www.google.it/search?sistemi+operativi

type customGoogleType: void { .q: string }

outputPort Google {
    Location: "socket://www.google.it:80"
    Protocol: https
    RequestResponse: search( customGoogleType )( undefined )
}


main
{
    request.q = "sistemi+operativi";
    searc@Google( request )( result )
}