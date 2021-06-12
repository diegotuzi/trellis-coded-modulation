clear all;
close all;
clc;

%% INPUT PARAMETERS
register_length=7;
BER_th=1e-3;
snr_start=0;
snr_step=1;


%% START SIMULATION
cd function\;
tcm_qam(register_length,BER_th,2,snr_start,snr_step);
tcm_qam(register_length,BER_th,3,snr_start,snr_step);
tcm_qam(register_length,BER_th,5,snr_start,snr_step);
figure(1)
show_graph(2,2);
figure(2)
show_graph(3,2);
figure(3)
show_graph(5,2);
cd ..\;

%%
% cd function\;
% show_graph(2,1);
% cd ..\;