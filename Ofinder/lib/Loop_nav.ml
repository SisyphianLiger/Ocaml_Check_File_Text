open Curses
open Cli 
open Ls
open Match_str
(* Take in Input 
   u
    From Ocaml.org docs 
    While loops are useful with references
    If we use a ref here that being false, 
    we are saying while the loop is not true 
    print_string q to quit and if we see that 
    the string.[0] is true then we set file_loop to true 
    setting the boolean value to the reference file_loop 
    to true terminating the loop

    Initialize an empty search string before the loop starts.
    In your loop, take each character input from read_line ()
    and append it to your search string.
    Apply your algorithms to the search string inside the loop.
    If you do this, every time a new character is inputted, 
    the search string would get longer by one character, 
    and the algorithms would be applied to an increasingly 
    longer string, just as you intended.

    I have a sentence and I want to ask more questions.

 *)


(* Letting user know if DIRECTORIES or FILES *)
let unpacker_str x = if x = 0 then "F" else "D"


(* Helper Function for sorting *)
let compare_ls ls_one ls_two = 
    match ls_one.ls_score, ls_two.ls_score with
    | None, None -> 0
    | Some _, None -> -1
    | None, Some _ -> 1
    | Some x, Some y -> compare x y


let exit_to_nvim index list = 
    let res = (List.nth index list).fd_str in
    Printf.printf "The place retrieved is %s \n" res;
    start_path res

let key_test path = 
    let main_window = initscr () in
    let _ = keypad main_window true in (* Enable special keys reading *)

    let _ = path in
    (* we take this and use it to display the results *) 
    let f_d_found = find_fdl path in
    
    (* Needed to read text contiguously *)
    let _ = cbreak () in
    let _ = noecho () in  

    let (maxy, maxx) = getmaxyx main_window in
    (* Window's Set Up *)

    let win_top = newwin (maxy * 7 / 10) maxx 2 0 in
    let win_bot = newwin (maxy / 10)  maxx (maxy * 9 / 10) 0  in
    box win_top (Char.code '|') (Char.code '=');
    box win_bot (Char.code '|') (Char.code '=');
    let _ = refresh () in

    let _ = mvaddstr 1 2 "FILES OR DIRECTORIES" in

    let _ = mvaddstr ((maxy * 9 / 10) - 1) 2 "SEARCH TERM BOX:" in
    let _ = mvaddstr ((maxy * 9 / 10) + 1) 3 "" in

    let _ = wrefresh win_top in 
    let _ = wrefresh win_bot in 

    let input_range = ((maxy * 7 / 10) - 2) in

    let enter = 10 in
    let escape = 27 in
    
    let top_index = ref 0 in
    let search_term = ref "" in    
    let run_loop = ref true in

    while !run_loop do
        let ch = getch () in
        match ch with
            | key_code when key_code = enter ->
                    (* Sends result string to finishing Function *)
                    run_loop := false

            | key_code when key_code = Key.up ->                    if !top_index <= input_range - 2 then top_index := !top_index + 1;
                                                                    (* Output the match str *)
                                                                    List.iter (fun x -> x.ls_score <- Some(make_str_matrix !search_term x.fd_str);
                                                                                        x.sub_str_pnt <- my_match_str x.fd_str !search_term) f_d_found;
                                                             
                                                                    (* Now we sort *)
                                                                    List.sort compare_ls f_d_found |> List.filteri (fun i _ -> i < input_range) |>
                                                                    List.iteri (fun i x -> 
                                                                            ignore(mvaddstr(input_range - i + 2) 2 ((unpacker_str x.file_or_dir) ^ " " ^  
                                                                                x.fd_str ^ "            "));
                                                                            if i = !top_index then 
                                                                                ignore(mvaddstr (input_range - i + 2) 2 ((unpacker_str x.file_or_dir) ^ " " ^  
                                                                                x.fd_str  ^ "     <===== "))
                                                                            else
                                                                                ignore(mvaddstr (input_range - i + 2) 2 ((unpacker_str x.file_or_dir) ^ " " ^  
                                                                                x.fd_str))
                                                                    );
                                                                    let _ = wrefresh win_top in 
                                                                    run_loop := true


            | key_code when key_code = Key.down ->                  if !top_index > 0 then top_index := !top_index - 1;

                                                                    (* Output the match str *)
                                                                    List.iter (fun x -> x.ls_score <- Some(make_str_matrix !search_term x.fd_str);
                                                                                        x.sub_str_pnt <- my_match_str x.fd_str !search_term) f_d_found;
                                                             
                                                                    (* Now we sort *)
                                                                    List.sort compare_ls f_d_found |> List.filteri (fun i _ -> i < input_range) |>
                                                                    List.iteri (fun i x -> 
                                                                            ignore(mvaddstr(input_range - i + 2) 2 ((unpacker_str x.file_or_dir) ^ " " ^  
                                                                                x.fd_str ^ "            "));
                                                                            if i = !top_index then 
                                                                                ignore(mvaddstr (input_range - i + 2) 2 ((unpacker_str x.file_or_dir) ^ " " ^  
                                                                                x.fd_str ^ "     <===== "))
                                                                            else
                                                                                ignore(mvaddstr (input_range - i + 2) 2 ((unpacker_str x.file_or_dir) ^ " " ^  
                                                                                x.fd_str))
                                                                    );
                                                                    let _ = wrefresh win_top in 
                                                                    run_loop := true

            | key_code when key_code = escape -> 
                   run_loop := false
                    
            | key_code when key_code = Key.left -> 
                    run_loop := true

            | key_code when key_code = Key.right -> 
                    run_loop := true

            | _  when (String.length !search_term) < (maxx - 5) ->  search_term := !search_term  ^ Char.escaped (Char.chr ch);            
                                                                    ignore(mvaddstr ((maxy * 9 / 10) + 1) 3 !search_term); 
                                                                    (* Output the match str *)
                                                                    List.iter (fun x -> x.ls_score <- Some(make_str_matrix !search_term x.fd_str);
                                                                                        x.sub_str_pnt <- my_match_str x.fd_str !search_term) f_d_found;
                                                             
                                                                    (* Now we sort *)
                                                                    List.sort compare_ls f_d_found |> List.filteri (fun i _ -> i < input_range) |>
                                                                    List.iteri (fun i x -> if i < input_range 
                                                                    then ignore(mvaddstr (input_range - i + 2) 2 ((unpacker_str x.file_or_dir) ^ " " ^  
                                                                    x.fd_str ) ));
                                                                    let _ = wrefresh win_top in 
                                                                    run_loop := true

        | _                                             ->   run_loop := true
    done;
    exit_to_nvim f_d_found !top_index;
    endwin ()




