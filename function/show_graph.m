function show_graph(k,opt)
    %% LOAD DATA
    switch k
        case 2
            mdl_name='TCM8AMPM_4QAM';
        case 3
            mdl_name='TCM16QAM_8AMPM';
        case 5
            mdl_name='TCM64QAM_32QAM';
    end
    
    switch opt
        case 1
            load(['..\saved_data\',mdl_name,'_sim_result']);
        case 2
            load(['..\data\',mdl_name,'_sim_result']);
    end
    
    %% GENERATE FIGURE
    h_UNCODED=semilogy(snr_vec,ber_UNCODED,'-*b');
    hold on;
    h_TCM=semilogy(snr_vec,ber_TCM,'-*r');
    h_TCM_tcm_bit_coded=semilogy(snr_vec,ber_tcm_bit_coded,'-*c');
    h_TCM_bit_uncoded=semilogy(snr_vec,ber_tcm_bit_uncoded,'-*g');
    hold off;
    grid on;
    set(h_UNCODED,'LineWidth',2.5)
    set(h_UNCODED,'MarkerSize',7)
    set(h_TCM,'LineWidth',2.5)
    set(h_TCM,'MarkerSize',7)
    % set(h_TCM_tcm_bit_coded,'LineWidth',2.5)
    % set(h_TCM_tcm_bit_coded,'MarkerSize',7)
    % set(h_TCM_bit_uncoded,'LineWidth',2.5)
    % set(h_TCM_bit_uncoded,'MarkerSize',7)
    legend([label_uncoded,' uncoded (',num2str(k),' bits/symbol)'],...
        [label_coded,'-pragmatic-',num2str(num_states),'-states (',num2str(k),' bits/symbol)'],...
        [label_coded,'-pragmatic-',num2str(num_states),'-states coded-bit'],...
        [label_coded,'-pragmatic-',num2str(num_states),'-states uncoded-bit']);
    set(gca,'LineWidth',1.2)

    index_x=max([find(ber_UNCODED, 1, 'last' ),find(ber_TCM, 1, 'last' ),...
        find(ber_tcm_bit_coded, 1, 'last' ),find(ber_tcm_bit_uncoded, 1, 'last' )]);
    set(gca,'XLim',[snr_vec(1) snr_vec(index_x)]);
    set(gca,'YLim',[max([ber_UNCODED(index_x),ber_TCM(index_x),ber_tcm_bit_coded(index_x),ber_tcm_bit_uncoded(index_x)]) 1]);
    title([label_coded,' VS ',label_uncoded]);
    ylabel('BER');
    xlabel('SNR(dB)');
end
