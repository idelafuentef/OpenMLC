clear all; close all; clc;
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(0,'DefaultAxesXGrid','on')
set(0,'DefaultAxesYGrid','on')
mlc=MLC2('GP_lorenz');
mlc.go(10);