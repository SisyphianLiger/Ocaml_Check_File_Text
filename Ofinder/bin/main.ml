(* open Lib.Cli *)
open Lib.Loop_nav
(* open Lib.Match_str *)
(* "/Users/ryanmac/Desktop/10.BootDev_Portfolio/Ofinder/" *)


let main () = 
    let path = "/Users/ryanmac/Desktop/10.BootDev_Portfolio/Ofinder/Ofinder" in 
    key_test path;
    let _ = Sys.command "nvim ." in
    ()

let () = main ()
