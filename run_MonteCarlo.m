n2=3; %number oof loops over the film thicknness (d)
n3=8; % number of loops over the 'escape cone probability' (ped)
n4=13; %number of loops over the inverse scattering length (isl)
iqe=0.8; %internal luminescence quantum efficiency
n=3E6; % number of photons used in the simulation
plots=true;
l=0; %for numbering of filename
d=400E-7; %determines first layer thickness
load('Example-data.mat');
for i=1:n2 %loop over film thickness
    d=d-100E-7; 
    ped=0.04;
    for j=1:n3 %loop over ped
        ped=ped+0.02; %determines stepsize of ped
        isl=0;
        for k=1:n4 %loop over isl
            if k >= 7
                isl=isl+200;%determines step size of isl
            else
                isl=isl+100;%determines step size of isl
            end
            results=MonteCarlo_code(n, iqe, ped, d, isl, plots,aspec,espec); %executes the Monte Carlo code
            save('filename.mat','-struct','results');
            load('filename.mat');
            l=l+1; %for numbering of filename
            d1=d*1E7;
            y=sprintf('esc=%4.3f-iqe=%4.3f-isl=%d-eqe=%5.4f-esc_d=%4.4f-esc_s=%4.4f-esc_tot=%4.4f-pr_eff=%4.3f-d=%3.0f', ped, iqe, isl,eqe,esc_d,esc_s,esc_eff,pr_eff,d1); 
            y2=sprintf('R%d-d=%3.0f-esc=%4.3f-isl=%d.txt', l,d1,ped,isl); %includes the thickness, ped and isl in the filename
            fileID = fopen(y2,'w');
            fprintf(fileID,'%38s\n',y); %places the simulated parameters in the first row
            fprintf(fileID,'%12.5f\n',emitted_d); % next 160 lines: directly emitted PL (wavelength 700-859 nm)
            fprintf(fileID,'%12.5f\n',emitted_s); % next 160 lines: scattered PL (wavelength 700-859 nm)
            fprintf(fileID,'%12.5f\n',emitted_d+emitted_s); % next 160 lines: total PL (wavelength 700-859 nm)
            fclose(fileID);
        end
    end
end
