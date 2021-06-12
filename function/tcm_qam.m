function tcm_qam(register_length,BER_th,k,snr_start,snr_step)
    %% CHOOSE SIMULATION TYPE
    warning off;
    [generator_c1,generator_c2]=choose_generator(register_length);
    num_states=2^(register_length-1);
    constlen_2=[register_length];
    codegen_2=[generator_c1 generator_c2];
    trellis_2=poly2trellis(constlen_2,codegen_2); % Set trellis structure
    K=2^k;
    m=k+1;
    M = 2^m; % Size of the signal constellation
    A=1;

    switch k
        case 2
            % pragmatic 2/3 Tcm 8AMPM VS 4QAM
            constlen=[1 register_length];
            codegen=[1 0 0; 0 generator_c1 generator_c2];
            trellis=poly2trellis(constlen,codegen); % Set trellis structure
            tb = 4*max(constlen);
            mapping_tcm=[(-1+3j) (3-1j) (3+3j) (-1-1j) (-3+1j) (1-3j) (1+1j) (-3-3j)];
            mdl_name='TCM8AMPM_4QAM';
            label_coded='TCM8AMPM';
            label_uncoded='4QAM';
            P_TCM=sum(abs(mapping_tcm).^2)/length(mapping_tcm);
            P_UNCODED=(K-1)/3*2*A^2;
            uncoded_bit=1;
            coded_bit=2;
            coded_bit_conv=[2,3];
            T=1;
        case 3
            % pragmatic 3/4 Tcm 16QAM VS 8AMPM
            constlen=[1 1 register_length];
            codegen=[1 0 0 0; 0 1 0 0; 0 0 generator_c1 generator_c2];
            trellis=poly2trellis(constlen,codegen); % Set trellis structure
            tb = 4*max(constlen);
            mapping_tcm=[(-1-1j) (3+3j) (-1+3j) (3-1j)...
                (-3-3j) (1+1j) (-3+1j) (1-3j)...
                (-3+3j) (1-1j) (-3-1j) (1+3j)...
                (-1+1j) (3-3j) (-1-3j) (3+1j)];
            mapping_uncoded=[(-1+3j) (-3+1j) (3+3j) (1+1j) (3-1j) (1-3j) (-1-1j) (-3-3j)];
            mdl_name='TCM16QAM_8AMPM';
            label_coded='TCM16QAM';
            label_uncoded='8AMPM'; 
            P_TCM=sum(abs(mapping_tcm).^2)/length(mapping_tcm);
            P_UNCODED=10;
            uncoded_bit=[1 2];
            coded_bit=3;
            coded_bit_conv=[3,4];
            T=1;
        case 5
            % Code for pragmatic 5/6 Tcm 64QAM VS 32QAM
            constlen=[1 1 1 1 register_length];
            codegen=[1 0 0 0 0 0; 0 1 0 0 0 0; 0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 generator_c1 generator_c2];
            trellis=poly2trellis(constlen,codegen); % Set trellis structure
            tb = 4*max(constlen);
            mapping_tcm=[...
                (-5-5j),(3+3j),(-5+3j),(3-5j),...
                (-1-1j),(7+7j),(-1+7j),(7-1j),...
                (-5-1j),(3+7j),(-5+7j),(3-1j),...
                (-1-5j),(7+3j),(-1+3j),(7-5j),...
                (-7-7j),(1+1j),(-7+1j),(1-7j),...
                (-3-3j),(5+5j),(-3+5j),(5-3j),...
                (-7-3j),(1+5j),(-7+5j),(1-3j),...
                (-3-7j),(5+1j),(-3+1j),(5-7j),...
                (-7-1j),(1+7j),(-7+7j),(1-1j),...
                (-3-5j),(5+3j),(-3+3j),(5-5j),...
                (-7-5j),(1+3j),(-7+3j),(1-5j),...
                (-3-1j),(5+7j),(-3+7j),(5-1j),...
                (-5-3j),(3+5j),(-5+5j),(3-3j),...
                (-1-7j),(7+1j),(-1+1j),(7-7j),...
                (-5-7j),(3+1j),(-5+1j),(3-7j),...
                (-1-3j),(7+5j),(-1+5j),(7-3j)...
            ];
%             plot(mapping_tcm,'*'); grid on; xlim([-8,8]); ylim([-8,8]);
            mdl_name='TCM64QAM_32QAM';
            label_coded='TCM64QAM';
            label_uncoded='32QAM';
            P_TCM=sum(abs(mapping_tcm).^2)/length(mapping_tcm);
            P_UNCODED=(K-1)/3*2*A^2;
            uncoded_bit=[1 2 3 4];
            coded_bit=5;
            coded_bit_conv=[5,6];
            T=1;
    end

    %% SIMULATION
    % LOG
    diary(['..\log\',datestr(now, 'yyyy.mm.dd_HH.MM.SS_'),mdl_name,'.txt']);
    
    snr=snr_start; 
    BER_exit=1;
    seed=uint32(sum(100*clock));
    n=BER_th^(-1)*10; % Number of bits to process

    startTime=clock;
    fprintf(['START TIME:\t\t\t', datestr(startTime,'dd-mm-yyyy HH:MM:SS\n')]);
    fprintf('\n%7s\t\t\t\t%10s\t\t%7s\t\t\t%8s\n',...
        'SNR(dB)','BER_UNCODED','BER_TCM','DURATION');
    stepTime=startTime;
    i=1;
    while(BER_exit>BER_th)
        snr_vec(i)=snr;
        
        % PERMETTERE AL MODELLO DI UTILIZZARE VARIABILI NEL WORKSPACE DELLA FUNZIONE
        cd ..\model\;
        load_system(mdl_name);
        hws = get_param(mdl_name, 'modelworkspace');
        list = whos; % Get the list of variables defined in the function
        N = length(list);
        % Assign everything in the model workspace
        for  h = 1:N
            hws.assignin(list(h).name,eval(list(h).name));
        end
        % END
        
        sim(mdl_name,n);
        cd ..\function\;
        
        % SERVE EVALIN PERCHE' IL MODELLO SALVA NEL WORKSPACE BASE
        ber_UNCODED(i)=evalin('base','ErrorVec_UNCODED(1)');
        ber_TCM(i)=evalin('base','ErrorVec_TCM_1(1)');
        ber_tcm_bit_coded(i)=evalin('base','ErrorVec_TCM_COD_1(1)');
        ber_tcm_bit_uncoded(i)= evalin('base','ErrorVec_TCM_bit_uncoded(1)');
        % END
       
        step_dur=etime(clock,stepTime);
        stepTime=clock;
        [hh,mm,ss]=sec_to_hms(step_dur);
        fprintf('%5.1f\t\t\t\t%0.1e\t\t\t%0.1e\t\t\t%dh %dm %.2fs\n'...
            ,snr,ber_UNCODED(i),ber_TCM(i),hh,mm,ss);
        BER_exit=max([ber_UNCODED(i),ber_TCM(i)]);
        snr=snr+snr_step;
        i=i+1;
    end
    
    stopTime=clock;
    fprintf(['\nSTOP TIME:\t\t\t', datestr(stopTime,'dd-mm-yyyy HH:MM:SS\n')]);
    duration=etime(stopTime,startTime);
    [hh,mm,ss]=sec_to_hms(duration);
    fprintf('DURATION:\t\t\t%dh %dm %.2fs\n\n',hh,mm,ss);
    beep

    %% SAVE RESULT
    savefile=['data\',mdl_name,'_sim_result.mat'];
    save(['..\',savefile],'snr_vec','ber_UNCODED','ber_TCM','ber_tcm_bit_coded',...
        'ber_tcm_bit_uncoded','num_states','label_uncoded','label_coded');
    display(['Results saved in ',savefile,'']);
    
    %% 
    save_system(mdl_name);
    close_system(mdl_name); 
    diary off;
    warning on;
end