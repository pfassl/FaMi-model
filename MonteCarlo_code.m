% n is the number of photons initially absorbed, iqe is the internal PL quantum efficiency,
% ped is the 'escape cone probability'
% d is the thickness of the films
% isl is the inverse scattering length
% ial is the wavelength dependent absorption coefficient
% aspec is the absorption coefficient spectrum with column 1 (wavelength) and column 2
% (abs-coeff in cm-1)
% espec is the internal emission spectrum with column 1 wavelength and column 2
% (data)
% plots makes plots if 'true'

function out=MonteCarlo_code(n, iqe, ped, d, isl, plots,aspec,espec)
%
abs_lambda=aspec(:,1); % wavelength array for absorption (700-859 nm in this example)
abs_spec=aspec(:,2); %absorption coefficient spectrum in units of alpha (1/cm)
%
emission_lambda=espec(:,1); %wavelength array for emisson (700-859 nm in this example)
emission_pdf=espec(:,2)/trapz(espec(:,2));% emission spectrum normalized to area of 1
emission_spec=cumtrapz(espec(:,2))/max(cumtrapz(espec(:,2))); 

if abs_lambda ~= emission_lambda
    warning('emission and absorption must have a common wavelength scale, results invalid')
end

dead=0; % number of photons that died
reabsorptions = 0; % number of reabsorption events that occured (can exceed number of injected photons as one photon can be reabsorbed many times
emitted_d=zeros(length(emission_lambda),1); %spectrum and number of directly emitted PL
emitted_s=zeros(length(emission_lambda),1); % spectrum and number of scattered PL

p.iqe=iqe;
p.isl=isl;
p.ped=ped;
p.bscat=1; % for simplicity it is assumed, that a scattering event always results in photon escape
for i=1:n
%
p.number = n;
p.state = 'absorbed';

    while not(strcmp(p.state, 'dead'))
        switch p.state
            case 'absorbed'
                p = absorbed(p);
            case 'propagated'
                p = propagated(p);
        end
    end
end
%calculates the parameters:
eqe=(sum(emitted_d)+sum(emitted_s))./n;  % external quantum efficiency
esc_d=sum(emitted_d)./((n+reabsorptions).*iqe);  % direct escape probability
esc_s=sum(emitted_s)./((n+reabsorptions).*iqe); % probability for scattering-induced escape
esc_eff=(sum(emitted_d)+sum(emitted_s))./((n+reabsorptions).*iqe);  %effective escape probability
pr_eff=reabsorptions/((1-esc_eff).*n); %PR "efficiency" - how many new photons are generated by one reabsorbed photon

%generates the output parameters:
out.eqe=eqe;
out.lam=emission_lambda;
out.emitted_d=emitted_d;  %spectrum of directly emitted PL
out.emitted_s=emitted_s;  % spectrum of scattered PL
out.esc_d=esc_d;
out.esc_s=esc_s;
out.esc_eff=esc_eff;
out.pr_eff=pr_eff;

if plots
    figure(12)
    clf
    hold on
    yyaxis left
    plot(abs_lambda, abs_spec);
    ylabel('Absorption coefficient (1/cm)')
    yyaxis right
    ylabel('PL intensity (a.u.)')
    plot(emission_lambda, emission_pdf);
    plot(emission_lambda, emitted_d./(sum(emitted_d)*(emission_lambda(2)-emission_lambda(1))));
    plot(emission_lambda, (emitted_d+emitted_s)./(sum(emitted_d+emitted_s)));
    legend('absorption coefficient','internal emission','directly emitted PL','integrating sphere emission','Location','northeast')
    title('PL spectra normalized to area under curve')
end

function a_out=absorbed(p)
    
    if rand <= p.iqe
        fate = 'emitted'; 
    else
        fate='dead';
    end

    switch fate
        case 'emitted'
            %choose a wavelength for the emitted photon
            [minValue,closestIndex] = min(abs(rand()- emission_spec));
            p.lam = emission_lambda(closestIndex);
            ial=abs_spec(abs_lambda==p.lam);
            if rand <= p.ped
                if rand(1,1)<=0.3  %30% of photons are considered to be reflected once at an interface and travel through the perovskite film once more
                    if (0+p.ped*rand(1,1)) <= p.ped*exp(-ial.*d.*(1 + 1.*rand(1,1)))  % a new dice to  account for a random starting point of a photon within the film
                        emitted_d(emission_lambda==p.lam)=emitted_d(emission_lambda==p.lam)+1; %increment the number of directly escaping photons (after being reflected once)
                        p.state='dead';
                    else
                        reabsorptions=reabsorptions+1;
                        p.state='absorbed';
                    end
                else %70% of the photons are considered to escape at the first arrival at an interface
                    if (0+p.ped*rand(1,1)) <= p.ped*exp(-ial.*d.*rand(1,1))  % a new dice to  account for a random starting point of a photon within the film
                    emitted_d(emission_lambda==p.lam)=emitted_d(emission_lambda==p.lam)+1; %increment the number of directly escaping photons (without being reflected once)
                    p.state='dead';
                    else
                        reabsorptions=reabsorptions+1;
                        p.state='absorbed';
                    end
                end
            else
                p.state='propagated';
            end
            
        case 'dead'
            dead=dead+1; %increment count of photons that died without emitting :(
            p.state='dead';
    end
    a_out=p;
end

function p_out=propagated(p)

    %it is actually not important for the simulation result how far the
    %photon propogates, all that is important is whether the photon was absorbed or
    %scattered at an event.

    ial=abs_spec(abs_lambda==p.lam);
    prob_abs=ial/(ial+p.isl); %probability that a photon was absorbed instead of scattered
    if rand < prob_abs
        fate = 'reabsorbed';
    else
        fate = 'scattered';
    end
    
    switch fate
        case 'reabsorbed'
            reabsorptions=reabsorptions+1;
            p.state='absorbed';
        case 'scattered'
            if rand <= p.bscat
                emitted_s(emission_lambda==p.lam)=emitted_s(emission_lambda==p.lam)+1; %increment the number of scattered and emitted photons
                p.state='dead';
            else
                p.state='propagated';
            end
    end

    p_out=p;
end

end
  

    

    
    
    
    
    