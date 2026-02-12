function [kl_divs] = fill_kl_divergence_mat(M)
    [Ms, Vs] = ts_M(M);
    N = size(M,1);
    kl_divs=zeros(N);
    for ii=1:N
        for jj=1:(ii-1)
            Miijj1=M;
            Miijj1(ii,jj)=Miijj1(ii,jj)+1;
            [musiijj1,Vsiijj1]=ts_M(Miijj1);
            kl1=norm_kl(musiijj1,Ms,Vsiijj1,Vs);
            Miijj2=M;
            Miijj2(jj,ii)=Miijj2(jj,ii)+1;
            [musiijj2,Vsiijj2]=ts_M(Miijj2);
            kl2=norm_kl(musiijj2,Ms,Vsiijj2,Vs);
            pij=normcdf( Ms(ii)-Ms(jj), 0, sqrt(1+Vs(ii)+Vs(jj)) );
            kl_gain=pij*kl1+(1-pij)*kl2;
            kl_divs(ii,jj)=kl_gain;
        end
    end
end