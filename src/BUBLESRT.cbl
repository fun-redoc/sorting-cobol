       IDENTIFICATION DIVISION.
       PROGRAM-ID. BUBLESRT.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       replace ==:maxlen:== by ==3==
               ==:maxval:== by ==999==.
       01 i pic 9(:maxlen:).
       01 j pic 9(:maxlen:).
       01 aux pic 9(3).
       LINKAGE SECTION.
       copy RSHCPY1 replacing ==:struct:== by ==dta==
                              ==:struct-maxlen:== by ==:maxlen:==
                              ==:struct-maxoccurs:== by ==:maxval:==.
       PROCEDURE DIVISION using dta.
           display "in bubble"
           *> perform buble sort
           PERFORM test after VARYING j from dta-len by -1 
                              until j <= 1
               perform test after varying i from 2 by 1 
                                  until i >= dta-len
                 move dta-elem(i - 1) to aux
                 if aux > dta-elem(i)
                 THEN
                    *> swap
                    move dta-elem(i) to dta-elem(i - 1)
                    move aux to dta-elem(i)
                 end-if
               end-perform
           END-PERFORM

           GOBACK.
