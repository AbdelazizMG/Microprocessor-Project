
               %Open config.json 
               json_filename = 'conf.json';
               json_config = jsondecode(fileread(json_filename));               
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               %Solve Questions in the PDF
               UART.NumberOfNonDataBits=0;
               UART.NumberOfDataBits=json_config(1).inputs.data_bits;
               UART.TotalNumberOfBits=0;
               UART.Bitduration = json_config(1).inputs.bit_duration;
               
               if(json_config(1).inputs.parity == "none")
                   UART.NumberOfNonDataBits= json_config(1).inputs.stop_bits + 1; %start and Stop Bits
               else
                   UART.NumberOfNonDataBits= json_config(1).inputs.stop_bits + 2; %start , parity and number of stop bits
                   end
               UART.TotalNumberOfBits = UART.NumberOfNonDataBits + UART.NumberOfDataBits;
               
               OUTPUT(1).protocol_name= "UART";
               
               OUTPUT(1).outputs.total_tx_time = UART.Bitduration * UART.TotalNumberOfBits * 2;
               OUTPUT(1).outputs.overhead = ( (UART.NumberOfNonDataBits *100) / UART.TotalNumberOfBits);
               OUTPUT(1).outputs.efficiency = ( (UART.NumberOfDataBits*100) / UART.TotalNumberOfBits);
               
               OUTPUT(2).protocol_name= "USB";
               
               OUTPUT(2).outputs.total_tx_time = UART.Bitduration * UART.TotalNumberOfBits * 2;
               OUTPUT(2).outputs.overhead = ( (UART.NumberOfNonDataBits *100) / UART.TotalNumberOfBits);
               OUTPUT(2).outputs.efficiency = ( (UART.NumberOfDataBits*100) / UART.TotalNumberOfBits);
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Open  input.txt file
               filename = 'input.txt';
               fileID = fopen(filename);
               formatspec = '%c';
               Array = fscanf(fileID,formatspec);                                     
               fclose(fileID);
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               % Read Data
               Element1=dec2bin(Array([1]),8);        % convert intered charater into binary
               Element2=dec2bin(Array([2]),8);        % convert intered charater into binary
               
               Element1 = str2double(Element1);       % make the binary (1,0) numbers not characters 
               Element2 = str2double(Element2);       % make the binary (1,0) numbers not characters 
                                          
               data = num2str(Element1)-'0';          % seperate them with spaces to be an array 
               data2 = num2str(Element2)-'0';         % seperate them with spaces to be an array  
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               %Modify Data for First Element (data)
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
               
               %Modify Data for Second Element (data2)
               if(json_config(1).inputs.data_bits == 8 && length(data2) == 7)      % make the data 8 bits
                     data2 = [ 0 data2 ] ;                
               elseif((json_config(1).inputs.data_bits == 8 && length(data2) == 8) || (json_config(1).inputs.data_bits == 7 && length(data2) == 7))  
                   % do nth       
               elseif(json_config(1).inputs.data_bits == 8 && length(data2) == 6)  % make the data 8 bits
                     data2 = [0 0 data2];  
               elseif(json_config(1).inputs.data_bits == 7 && length(data2) == 6)  % make the data 8 bits
                     data2 = [0 data2];        
               end
               data2 = flip(data2);                   % flip data to make LSB is the MSB and vice versa   
               
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
               frame2 = [start_bit data2  Onestop_Noparity_idle_bit];
               frame= [ idle_start_bit data Onestop_Noparity_idle_bit ];
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               %Create Frame Format for second element to be displayed
               if(json_config(1).inputs.stop_bits == 1 && json_config(1).inputs.parity == "none" )
                    frame2 = [ start_bit data2 Onestop_Noparity_idle_bit];                 
               elseif (json_config(1).inputs.stop_bits == 2 && json_config(1).inputs.parity == "none")
                    frame2 = [ start_bit data2 Twostop_Noparity_idle_bit];
               elseif (json_config(1).inputs.stop_bits == 1 && (json_config(1).inputs.parity == "even"||json_config(1).inputs.parity == "odd"))
                    number_of_ones = nnz(data2);        %count number of ones in the data
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
                 frame2 = [ start_bit data2 Onestop_parity_idle_bit];
                         
               elseif (json_config(1).inputs.stop_bits == 2 && (json_config(1).inputs.parity == "even"||json_config(1).inputs.parity == "odd"))
                      number_of_ones = nnz(data2);        %count number of ones in the data
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
                    frame2 = [ start_bit data2 Twostop_parity_idle_bit];                    
               end   
               %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               %Create Frame Format for first element to be displayed
               if(json_config(1).inputs.stop_bits == 1 && json_config(1).inputs.parity == "none" )
                    frame = [ idle_start_bit data Onestop_Noparity_idle_bit frame2];                 
               elseif (json_config(1).inputs.stop_bits == 2 && json_config(1).inputs.parity == "none")
                    frame = [ idle_start_bit data Twostop_Noparity_idle_bit frame2];
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
                 frame = [ idle_start_bit data Onestop_parity_idle_bit frame2];
                         
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
                    frame = [ idle_start_bit data Twostop_parity_idle_bit frame2];                    
               end
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              %draw Frame
             % stairs ([frame,frame(end)]); 
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
             %Generate output.json
             
             % Convert to JSON text
             jsonText2 = jsonencode(OUTPUT,'PrettyPrint',true)
             % Write to a json file
             fid = fopen('output.json', 'w');
             fprintf(fid, '%s', jsonText2);
             fclose(fid);
             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
             
              USB.synch_pattern = [ 0 0 0 0 0 0 0 1];
              USB.PID = [0 0 0 0 0 0 0 1];
              USB.EOP = [ 0 0 1];
              USB.data = num2str(Element1)-'0';                       % seperate them with spaces to be an array 
              USB.data2 = num2str(Element2)-'0';                      % seperate them with spaces to be an array 
              USB_frame = [USB.synch_pattern USB.PID USB.data USB.EOP];
              
              
              USB.frame_length = length(USB_frame);
              
              USB.output = [1 USB.synch_pattern USB.PID USB.data USB.EOP];
              
                
              for counter = 1 : USB.frame_length
                  if ( USB_frame(counter) == 1 )
                      USB.output(counter+1)= USB.output(counter);
                  else
                      USB.output(counter+1) = ~USB.output(counter);
                  end
              end
              USB.addressing = json_config(2).inputs.destination_address;  
              USB.addressing = dec2bin(USB.addressing,11);
              USB.addressing = num2str(USB.addressing)-'0';
              
              
                             % Open  input.txt file
               filename_s = 'inputdata.txt';
               fileID_s = fopen(filename_s);
               formatspec = '%c';
               Array_s = fscanf(fileID_s,formatspec);                                     
               fclose(fileID_s);
               
                              % Read Data
               Element12= logical(dec2bin(Array_s([1]),8)-'0');        % convert intered charater into binary
               Element22= logical(dec2bin(Array_s([2]),8)-'0');        % convert intered charater into binary
            
    % out = reshape(Array_s,1280,[]);
     
%     out = logical (dec2bin(out,8)-'0');
               
 %    out = reshape(out',[1 size(out,1) * size(out,2)]);


          USB.synch_pattern = [ 0 0 0 0 0 0 0 1];
              USB.PID = [0 0 0 0 0 0 0 1];
              USB.PID2 = [0 0 0 0 0 0 1 0];
              USB.EOP = [ 0 0 0];
              USB.addressing = json_config(2).inputs.destination_address;  
              USB.addressing = dec2bin(USB.addressing,11);
              USB.addressing = num2str(USB.addressing)-'0';
               out = reshape(Array_s,1280,[]);                            %Format the text into characters each on a line
               out = logical (dec2bin(out,8)-'0');                      % convert those characters into their binary equivalent
               out = reshape(out',[1 size(out,1) * size(out,2)]);       % convert it back to 1 dimensional array
               counter_data = 1;
              for counter = 1 :1024
                  USB.data(counter) = out(counter);
              end
              for counter = 1024:2048
                  USB.data2(counter_data) = out(counter);  
                  counter_data = counter_data +1;
              end
              
              USB.data = flip(USB.data);
              USB.data2 = flip(USB.data2);
              USB_frame = [USB.synch_pattern USB.PID USB.addressing USB.data USB.EOP USB.synch_pattern USB.PID2 USB.addressing  USB.data2 USB.EOP];            
              USB.output = [1 USB.synch_pattern USB.PID USB.addressing USB.data USB.EOP USB.synch_pattern USB.PID2 USB.addressing  USB.data2 USB.EOP]; %initial value for the output
              USB.frame_length = length(USB_frame);
              USB.output_length = length(USB.output);

test = [1 1 1];
test2 = ~test;

%0   1   1   1   0   1   0   0   0   0   1   0   0   0   0   0   0   1   1   0   0   1   1   0   0   1   1   0   1   1   1   1






