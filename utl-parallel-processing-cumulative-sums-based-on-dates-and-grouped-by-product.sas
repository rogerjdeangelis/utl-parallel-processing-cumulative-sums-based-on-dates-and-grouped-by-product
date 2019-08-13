
Parallel processing cumulative sums based on dates and grouped by product                                                         
                                                                                                                                  
github                                                                                                                            
https://tinyurl.com/y44kgdo8                                                                                                      
https://github.com/rogerjdeangelis/utl-parallel-processing-cumulative-sums-based-on-dates-and-grouped-by-product                  
                                                                                                                                  
SAS forum                                                                                                                         
https://tinyurl.com/y6egbwzo                                                                                                      
https://communities.sas.com/t5/SAS-Programming/Cumulative-based-on-dates-and-multiple-variables/m-p/580669                        
                                                                                                                                  
                                                                                                                                  
You could also speed ups Pauls solution by muti-tasking..                                                                         
You may be able to use SPDE                                                                                                       
                                                                                                                                  
If you are on a server with 1,000s of cores you cal increase                                                                      
the mutiprogramming level.                                                                                                        
                                                                                                                                  
 Method                                                                                                                           
                                                                                                                                  
  a.  Suppose you have 8 products and 500 locations  A1-A500, B1-B100 ...                                                         
  a.  Create an index on product ( ie A, B, C .. H)                                                                               
  b.  Suppose you have 8 cores available                                                                                          
  c.  Run 8 taks simultaneously                                                                                                   
                                                                                                                                  
                                                                                                                                  
*_                   _                                                                                                            
(_)_ __  _ __  _   _| |_                                                                                                          
| | '_ \| '_ \| | | | __|                                                                                                         
| | | | | |_) | |_| | |_                                                                                                          
|_|_| |_| .__/ \__,_|\__|                                                                                                         
        |_|                                                                                                                       
;                                                                                                                                 
                                                                                                                                  
data have ;                                                                                                                       
  input (UniqueKey Product) (:$2.) Location Week :date. WKFactor Value ;                                                          
  format week yymmdd10. ;                                                                                                         
  cards ;                                                                                                                         
A1      A      1      07-Jan-19      4      43      94                                                                            
A1      A      1      14-Jan-19      5       2      76                                                                            
A1      A      1      21-Jan-19      4      27      74                                                                            
A1      A      1      28-Jan-19      4      22      47                                                                            
A1      A      1      04-Feb-19      4      22      25                                                                            
A1      A      1      11-Feb-19      4       3       3                                                                            
A2      A      2      07-Jan-19      2      31      66                                                                            
A2      A      2      14-Jan-19      2      35      76                                                                            
A2      A      2      21-Jan-19      2      41      47                                                                            
A2      A      2      28-Jan-19      2       6       6                                                                            
B1      B      1      07-Jan-19      3      22     101                                                                            
B1      B      1      14-Jan-19      2      34      79                                                                            
B1      B      1      21-Jan-19      3      45      97                                                                            
B1      B      1      28-Jan-19      5      22      52                                                                            
B1      B      1      04-Feb-19      2      30      30                                                                            
;                                                                                                                                 
run ;                                                                                                                             
                                                                                                                                  
*            _               _                                                                                                    
  ___  _   _| |_ _ __  _   _| |_                                                                                                  
 / _ \| | | | __| '_ \| | | | __|                                                                                                 
| (_) | |_| | |_| |_) | |_| | |_                                                                                                  
 \___/ \__,_|\__| .__/ \__,_|\__|                                                                                                 
                |_|                                                                                                               
;                                                                                                                                 
                                                                                                                                  
                                                                                                                                  
SD1.DESIREA total obs=10                                                                                                          
                                                                     |                                                            
  UNIQUEKEY  PRODUCT LOCATION    WEEK     WKFACTOR VALUE  DESIREDSUM |  RULES (use wkfactor for cum limit)                        
                                                                     |  ==================================                        
     A1         A        1     07-Jan-19     4      43       94      |  4 weeks = 43+2+27+22 = 94                                 
     A1         A        1     14-Jan-19     5       2       76      |  5 weeks=  2+27+22+3  = 76                                 
     A1         A        1     21-Jan-19     4      27       74      |                                                            
     A1         A        1     28-Jan-19     4      22       47      |                                                            
     A1         A        1     04-Feb-19     4      22       25      |                                                            
     A1         A        1     11-Feb-19     4       3        3      |                                                            
     A2         A        2     07-Jan-19     2      31       66      |                                                            
     A2         A        2     14-Jan-19     2      35       76      |                                                            
     A2         A        2     21-Jan-19     2      41       47      |                                                            
     A2         A        2     28-Jan-19     2       6        6      |                                                            
                                                                                                                                  
     B1         B        1     07-Jan-19     3      22      101      | Task 2                                                     
     B1         B        1     14-Jan-19     2      34       79      |                                                            
     B1         B        1     21-Jan-19     3      45       97      |                                                            
     B1         B        1     28-Jan-19     5      22       52      |                                                            
     B1         B        1     04-Feb-19     2      30       30      |                                                            
                                                                                                                                  
*          _       _   _                                                                                                          
 ___  ___ | |_   _| |_(_) ___  _ __                                                                                               
/ __|/ _ \| | | | | __| |/ _ \| '_ \                                                                                              
\__ \ (_) | | |_| | |_| | (_) | | | |                                                                                             
|___/\___/|_|\__,_|\__|_|\___/|_| |_|                                                                                             
                                                                                                                                  
;                                                                                                                                 
                                                                                                                                  
* save macro in your autocall library;                                                                                            
                                                                                                                                  
proc sql;                                                                                                                         
  create index product on have                                                                                                    
;quit;                                                                                                                            
                                                                                                                                  
%macro prd(p=A);                                                                                                                  
/* %let product=B;   */                                                                                                           
libname sd1 "d:/sd1";                                                                                                             
proc sql;                                                                                                                         
   create                                                                                                                         
      table sd1.desire&product as                                                                                                 
  select                                                                                                                          
      uniquekey                                                                                                                   
     ,product                                                                                                                     
     ,location                                                                                                                    
     ,week format=date9.                                                                                                          
     ,wkfactor                                                                                                                    
     ,value                                                                                                                       
     ,(                                                                                                                           
        select                                                                                                                    
            sum(value)                                                                                                            
        from                                                                                                                      
            work.have                                                                                                             
        where                                                                                                                     
            product = "&product"                                                                                                  
            and uniquekey=a.uniquekey                                                                                             
            and week >= a.week                                                                                                    
            and week <= intnx('week', a.week, a.wkfactor)                                                                         
      ) as desiredsum                                                                                                             
    from                                                                                                                          
       work.have as a                                                                                                             
    where                                                                                                                         
      product = "&product"                                                                                                        
;quit;                                                                                                                            
%mend prd;                                                                                                                        
                                                                                                                                  
* UNTESTED MUTI-TASKING - I HAVE USE DTHIS MANY TIMES ;                                                                           
                                                                                                                                  
%let _s=%sysfunc(compbl(/sas/sashom5/SASFoundation/9.4/sasexe/sas -memsize 4gb                                                    
   -sysin /dev/null -log /dev/null -autoexec &_r/oto/batch_autoexec.sas)) ;                                                       
                                                                                                                                  
systask kill sys01 sys02 sys03 sys04 sys05 sys06 sys07 sys08;                                                                     
                                                                                                                                  
systask command "&_s -altlog &_r/log/unq_hsh01.log -termstmt '%nrstr(%unq(P=A))'" taskname=sys01;                                 
systask command "&_s -altlog &_r/log/unq_hsh02.log -termstmt '%nrstr(%unq(P=B))'" taskname=sys02;                                 
systask command "&_s -altlog &_r/log/unq_hsh03.log -termstmt '%nrstr(%unq(P=C))'" taskname=sys03;                                 
systask command "&_s -altlog &_r/log/unq_hsh04.log -termstmt '%nrstr(%unq(P=D))'" taskname=sys04;                                 
systask command "&_s -altlog &_r/log/unq_hsh05.log -termstmt '%nrstr(%unq(P=E))'" taskname=sys05;                                 
systask command "&_s -altlog &_r/log/unq_hsh06.log -termstmt '%nrstr(%unq(P=F))'" taskname=sys06;                                 
systask command "&_s -altlog &_r/log/unq_hsh07.log -termstmt '%nrstr(%unq(P=G))'" taskname=sys07;                                 
systask command "&_s -altlog &_r/log/unq_hsh08.log -termstmt '%nrstr(%unq(P=H))'" taskname=sys08;                                 
                                                                                                                                  
waitfor sys01 sys02 sys03 sys04 sys05 sys06 sys07 sys08;                                                                          
                                                                                                                                  
* keep the view unless final deliverable? ;                                                                                       
data sd1.prds/view=sd1.prds;                                                                                                      
   set                                                                                                                            
     sd1.A                                                                                                                        
     sd1.B                                                                                                                        
     sd1.C                                                                                                                        
     sd1.D                                                                                                                        
     sd1.E                                                                                                                        
     sd1.F                                                                                                                        
     sd1.G                                                                                                                        
     sd1.H                                                                                                                        
   ;                                                                                                                              
run;quit;                                                                                                                         
                                                                                                                                  
                                                                                                                                  
