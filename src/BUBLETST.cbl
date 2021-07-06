       IDENTIFICATION DIVISION.
       PROGRAM-ID. BUBLETST.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       replace ==:maxlen:== by ==3==
               ==:maxval:== by ==999==.
       01 i pic 9(:maxlen:).
       01 j pic 9(:maxlen:).
       01 curdate.
          05 curdate-num-part pic 9(16).
          05 curdate-rest pic x(5).
       01 rnd.
          05 frnd pic 9V99999999999 value zeroes.
          05 irnd pic 9(:maxlen:) value zeroes.
       01 len-from-param pic x(:maxlen:).
       01 max-len pic 9(:maxlen:) value :maxval:.
       01 is-sorted-flag pic 9 binary.
           88 is-sorted value 1.
           88 is-not-sorted value 0.
       01 out-line pic x(80) value spaces.
       01 time-measure.
           05 start-time.
              10 start-time-num pic 9(16).
              10 start-time-discard pic x(5).
           05 end-time.
              10 end-time-num pic 9(16).
              10 ent-time-discard pic x(5).
           05 delta-time pic 9(16).
       copy RSHCPY1 replacing ==:struct:== by ==dta==
                              ==:struct-maxlen:== by ==:maxlen:==
                              ==:struct-maxoccurs:== by ==:maxval:==.
       copy RSHCPY1 replacing ==:struct:== by ==aux-dta== 
                              ==:struct-maxlen:== by ==:maxlen:==
                              ==:struct-maxoccurs:== by ==:maxval:==.
       LINKAGE SECTION.
       01  PARM-BUFFER.
          05  PARM-LENGTH         pic S9(4) comp.
          05  PARM-DATA           pic X(256).
       PROCEDURE DIVISION using PARM-BUFFER.
           display "-------------"
           display "----START----"
           display "-------------"

           move PARM-DATA(1:PARM-LENGTH) to len-from-param
           COMPUTE max-len = LENGTH OF dta-grp / LENGTH OF dta-elem

           DISPLAY "PARM is " len-from-param
           display "max-len = " max-len
           if len-from-param > max-len
           THEN
              display "PARM is too big"
              display " max len is " max-len
              DISPLAY " but PARM is " PARM-DATA(1:PARM-LENGTH)
              display " arr len is" LENGTH of dta-grp
              display " elem len is" LENGTH of dta-elem
              move 16 to RETURN-CODE
              GOBACK
           end-if.

           move len-from-param to dta-len
           display "dta-len is " dta-len

           PERFORM seed-random.
           display "dta-len is " dta-len
           PERFORM test after VARYING i from 1 by 1 until i >= dta-len
              perform gen-random
      *       if dta-len not = 999
      *       then
      *         display "abort due to error:"
      *         display "dta-len is " dta-len
      *         display "i is " i
      *         display "frnd is " frnd
      *         display "irnd is " irnd
      *         goback
      *       end-if
              move irnd to dta-elem(i)
           END-PERFORM
           display "dta-len is " dta-len
           COMPUTE max-len = LENGTH OF dta-grp / LENGTH OF dta-elem

           display "before sort (" max-len ", " dta-len ")"
      *    perform display-dta

           move dta to aux-dta

           move function CURRENT-DATE to start-time
           call "QUICKSRT" using dta
           move function CURRENT-DATE to end-time
           if RETURN-CODE = 0
           then
              display "sorted with qsort"
              set is-sorted to true
              perform check-sorted
              if is-sorted
              then
                 display "qsort successfull"
              else
                 display "qsort failed"
              end-if
           else
              display "failed with code: " RETURN-CODE
           end-if
           compute delta-time = end-time-num - start-time-num

           perform display-dta

           display "duration: " delta-time


           move aux-dta to dta

           move function CURRENT-DATE to start-time
           call "BUBLESRT" using dta
           move function CURRENT-DATE to end-time
           if RETURN-CODE = 0
           then
              display "sorted with bublesrt"
              set is-sorted to true
              perform check-sorted
              if is-sorted
              then
                 display "bsort successfull"
              else
                 display "bsort failed"
              end-if
           else
              display "failed with code: " RETURN-CODE
           end-if
           compute delta-time = end-time-num - start-time-num
           display "duration: " delta-time

           display "-----------"
           display "----END----"
           display "-----------"

           goback.

       gen-random section.
           compute frnd = function RANDOM
           move frnd(4:3) to irnd.
           continue.

       seed-random SECTION .
           move FUNCTION CURRENT-DATE to curdate
           compute frnd = Function RANDOM (curdate-num-part)
           continue.

       check-sorted section.
           set is-sorted to true
           perform varying i from 1 by 1 until i >= dta-len
             if not (dta-elem(i) <= dta-elem(i + 1))
             then
              set is-not-sorted to true
              EXIT PERFORM
             end-if
           end-perform
           continue.

       display-dta section.
           move 1 to j
           perform test after varying i from 1 by 1 
                              until dta-len <= i
              if function MOD (i 20) = 0
              THEN
                 display out-line
                 move spaces to out-line
                 move 1 to j
              else
                 move dta-elem(i) to out-line(j:LENGTH OF dta-elem(i))
                 add 4 to j
              end-if
           END-PERFORM
           continue.