component restpath="/hello" rest="true"{
    remote any function helloRailo() httpmethod="GET" {
        return "Hello, Railo!";
    }
    remote any function helloURL(string a restargsource="Path") httpmethod="GET" restpath="{a}" {
        return "Hello, #ARGUMENTS.a#!";
    }
    remote any function helloFORM(string a restargsource="Form") httpmethod="POST" {
        return "Hello, #ARGUMENTS.a#!";
    }
}
