%                             read .txt file as file
% filename = 'input.txt';
% file = fileread(filename);
%-------------------------------------------------------------------------------------
%                             read json file
%fname = 'test-json.json';
%file = jsondecode(fileread(fname));
%-------------------------------------------------------------------------------------
%                            extract data from .txt file as integers
%fileID = fopen ('input.txt','r');
%formatspec = '%f';
%Array = fscanf(fileID,formatspec);  
% Note: to Access Certain Element use  A([1]) for first element and so on..
% This code logic works with data = 1 2 3            
%fclose(fileID);
%x=[1,2,3];
%plot(x,Array);
%--------------------------------------------------------------------------------------
%                           extract data from .txt file as characters
%filename = 'input.txt';
%fileID = fopen(filename);
%formatspec = '%c';
%Array = fscanf(fileID,formatspec);  
% Note: to Access Certain Element use  Array(1) for first element ,
%if data = 123 , (Work with this).
% if data = 1 2 3   ->   Array([1]) for first element                                    
%fclose(fileID);
%--------------------------------------------------------------------------------------

               %Open config.json 
               json_filename = 'conf.json';
               json_config = jsondecode(fileread(json_filename));           
           
               % Open  input.txt file
               filename = 'input.txt';
               fileID = fopen(filename);
               formatspec = '%c';
               Array = fscanf(fileID,formatspec);                                     
               fclose(fileID);
               
               % Read Data
               Element1=dec2bin(Array([1]),8);        % convert intered charater into binary

               Element1 = str2double(Element1);       % make the binary (1,0) numbers not characters 
                  
               %Remove Error Message  
           
              
                % Data               
               data = num2str(Element1)-'0';                                              % seperate them with spaces to be an array 
               
               try_length = length(data);
               
               if(json_config(1).inputs.data_bits == 8 && length(data) == 7)      % make the data 8 bits
                     data = [ 0 data ] ;                
               elseif((json_config(1).inputs.data_bits == 8 && length(data) == 8) || (json_config(1).inputs.data_bits == 7 && length(data) == 7))  
                   % do nth       
               elseif(json_config(1).inputs.data_bits == 8 && length(data) == 6)  % make the data 8 bits
                     data = [0 0 data];  
               elseif(json_config(1).inputs.data_bits == 7 && length(data) == 6)  % make the data 8 bits
                     data = [0 data];        
               end
               data = flip(data);                   % flip data to make LSB is the MSB and vice versa
               
                %Constants
               idle_bit = 1;
               start_bit = 0;
               parity_bit = 0;
               stop_bit = 1;
               
               idle_start_bit = [idle_bit start_bit];
               Onestop_Noparity_idle_bit = [stop_bit idle_bit];
               Twostop_Noparity_idle_bit = [stop_bit stop_bit idle_bit];
               
               Onestop_parity_idle_bit = [0 0 0];
               Twostop_parity_idle_bit = [0 0 0];
               
               %Frame
               frame= [ idle_start_bit data Onestop_Noparity_idle_bit ];
               
               

               
               if(json_config(1).inputs.stop_bits == 1 && json_config(1).inputs.parity == "none" )
                    frame = [ idle_start_bit data Onestop_Noparity_idle_bit];                
               elseif (json_config(1).inputs.stop_bits == 2 && json_config(1).inputs.parity == "none")
                    frame = [ idle_start_bit data Twostop_Noparity_idle_bit];
               elseif (json_config(1).inputs.stop_bits == 1 && (json_config(1).inputs.parity == "even"||json_config(1).inputs.parity == "odd"))
                    number_of_ones = nnz(data);        %count number of ones in the data
                    if(json_config(1).inputs.parity == "even" && mod(number_of_ones,2) == 0)
                        parity_bit =0;
                    elseif ( (json_config(1).inputs.parity == "even" && mod(number_of_ones,2) ~= 0))
                        parity_bit =1;
                    elseif ( (json_config(1).inputs.parity == "odd" && mod(number_of_ones,2) == 0))
                        parity_bit =1;
                    elseif ( (json_config(1).inputs.parity == "odd" && mod(number_of_ones,2) ~= 0))
                        parity_bit =0;  
                    end
                 Onestop_parity_idle_bit = [parity_bit stop_bit  idle_bit];  
                 frame = [ idle_start_bit data Onestop_parity_idle_bit];
                         
               elseif (json_config(1).inputs.stop_bits == 2 && (json_config(1).inputs.parity == "even"||json_config(1).inputs.parity == "odd"))
                      number_of_ones = nnz(data);        %count number of ones in the data
                    if(json_config(1).inputs.parity == "even" && mod(number_of_ones,2) == 0)
                        parity_bit =0;
                    elseif ( (json_config(1).inputs.parity == "even" && mod(number_of_ones,2) ~= 0))
                        parity_bit =1;
                    elseif ( (json_config(1).inputs.parity == "odd" && mod(number_of_ones,2) == 0))
                        parity_bit =1;
                    elseif ( (json_config(1).inputs.parity == "odd" && mod(number_of_ones,2) ~= 0))
                        parity_bit =0;  
                    end
                    Twostop_parity_idle_bit = [parity_bit stop_bit stop_bit  idle_bit];     
                    frame = [ idle_start_bit data Twostop_parity_idle_bit];                    
               end
               



               

              stairs ([frame,frame(end)]); 



















