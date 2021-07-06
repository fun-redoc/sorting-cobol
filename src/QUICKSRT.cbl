      *>-----------------------------------------------------------------
      * qsort algorithm, usually recursive
      * in this implementation recursion is implemented
      * using an implicite stack
      * basic algorithm:
      * qsort :: ord a => [a] -> [a]
      * qsort [] = []
      * qsort (pivot: reminder) =
      *     let (head,tail) = foldl (\(l,r)e -> if e < pivot then (e:l,r) else (
      *      in qsort head++[pivot]++qsort tail
      *>-----------------------------------------------------------------
       identification division.
       program-id. quicksrt.
       data division.
       working-storage section.
      *  stack has to be 4 times log2(len) big i think worst case
      * .                4 pushes each of the log2(len) branches
       replace ==:maxlen:== by ==3==
               ==:maxoccurs:== by ==999==
               ==:maxsstackoccurs:== by ==40==.
       01 qsort-section.
         10 swap pic 9(:maxlen:).
         10 idx pic 9(:maxlen:).
         10 ridx pic 9(:maxlen:).
         10 lidx pic 9(:maxlen:).
         10 pivot  pic 9(:maxlen:).
         10 endi pic 9(:maxlen:).
         10 begi pic 9(:maxlen:).
         10 pivoti pic 9(:maxlen:).
         10 stackp pic 9(:maxlen:).
         10 maxstackp pic 9(:maxlen:) value 0.
         10 maxstacklen pic 9(:maxlen:).
         10 required-stack-len pic 9(:maxlen:).
         10 stack-group.
            15 stack pic 9(:maxlen:) occurs :maxsstackoccurs: times.
       linkage section.
       copy RSHCPY1 replacing ==:struct:== by ==dta==
                              ==:struct-maxlen:== by ==:maxlen:==
                              ==:struct-maxoccurs:== by ==:maxoccurs:==.
       procedure division using dta.
       main section.
           display "hello in qsort"
           *> check ranges
           if dta-len > :maxoccurs:
           then
              display "to long array to sort."
              move 16 to return-code
              goback
           end-if.
           if length of dta-elem > :maxoccurs:
           then
              display "to big array to sort"
              move 16 to return-code
              goback
           end-if.
           compute maxstacklen = length of stack-group
                               / length of  stack
           if 4 * ((function log(dta-len)) /
                   (function log(2)))
              > maxstacklen
           then
              display "maxstacklen = " maxstacklen
              compute required-stack-len  = 4
                                          * function log(dta-len)
                                          / function log(2)
              display "logs.. = " required-stack-len

              display "stack is to small for this data (" dta-len ")"
              move 16 to return-code
              goback
           end-if.

           *> initilize stack
           move 1 to stackp.
           *> initialize sort range
           move 1 to begi
           move dta-len to endi
           *> push initial sort range to stack
           move begi to stack(stackp)
           perform inc-stackp
           move endi to stack(stackp)
           perform inc-stackp

           *> recursivelly sort
           perform test after until stackp <= 1
              *> pop from stack
              perform dec-stackp
              move stack(stackp) to endi
              perform dec-stackp
              move stack(stackp) to begi

              *> move elements smaller than pivot to the left
              *>               bigger  than pivot to the right
              compute pivoti = endi
              move dta-elem(pivoti) to pivot

              move begi to lidx
              move endi to ridx

              perform test after varying lidx from begi by 1 
                                 until lidx >= pivoti
                 if dta-elem(lidx) > pivot
                 then
                    move dta-elem(lidx) to swap
                    perform varying idx from lidx by 1
                            until idx >= pivoti
                       move dta-elem(idx + 1) to dta-elem(idx)
                    end-perform
                    move swap to dta-elem(pivoti)
                    subtract 1 from pivoti
                    subtract 1 from lidx
                 end-if
              end-perform

      d       display "------------------------------------"
      d       display "begi=" begi " endi=" endi
      d       display "pivoti=" pivoti " pivot=" pivot
      d       perform varying idx from begi by 1 until idx > endi
      d          display "  dta-elem(" idx ") = " dta-elem(idx)
      d       end-perform
      d       display "------------------------------------"

              *> push to stack left
              if pivoti > begi
              then
                 move begi to stack(stackp)
                 perform inc-stackp
                 compute stack(stackp) = (pivoti - 1)
                 perform inc-stackp
              end-if

              *> push to stack right
              if pivoti < endi
              then
                 compute stack(stackp) = (pivoti + 1)
                 perform inc-stackp
                 move endi to stack(stackp)
                 perform inc-stackp
              end-if
           end-perform
           move 0 to return-code
           display "maxstackp = " maxstackp
           goback.

       inc-stackp section.
           add 1 to stackp
      d    compute maxstackp = function max (maxstackp stackp)
           if stackp > maxstacklen
           then
              display "stackp overflow = " stackp
              move 16 to return-code
              goback
           end-if
           continue.

       dec-stackp section.
           subtract 1 from stackp
           if stackp < 1
           then
              display "stackp underflow"
              move 16 to return-code
              goback
           end-if
           continue.
