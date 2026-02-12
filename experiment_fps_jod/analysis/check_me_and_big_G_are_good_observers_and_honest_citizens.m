gd = load('/auto/homes/am2442/Documents/motion_quality/experiment_fps_jod/results/mat/mat_3_vel_gd1.mat');
am = load('/auto/homes/am2442/Documents/motion_quality/experiment_fps_jod/results/mat/mat_3_vel_am1.mat');
all = load('/auto/homes/am2442/Documents/motion_quality/experiment_fps_jod/results/mat/mat_3_vel_all_obs.mat');

Mall = all.M;
Mam = am.M;
Mgd = gd.M;
ids1 = 1:24;
ids2 = 25:48;
ids3 = 49:72;
Mall(ids1,ids1) = 0;
Mall(ids2,ids2) = 0;
Mall(ids3,ids3) = 0;
Mam(ids1,ids1) = 0;
Mam(ids2,ids2) = 0;
Mam(ids3,ids3) = 0;
Mgd(ids1,ids1) = 0;
Mgd(ids2,ids2) = 0;
Mgd(ids3,ids3) = 0;
Mam = Mam- Mgd;

Mfall = Mall+Mall';
Mfam = Mam+Mam';
Mfgd = Mgd+Mgd';



[rowall,collall] = find(Mfall>0);
[rowam,collam] = find(Mfam>0);
[rowgd,collgd] = find(Mfgd>0);

pairsam = [];
for ii = 1:numel(rowam)
    for jj = 1:numel(rowall)
        if rowam(ii)==rowall(jj) && collam(ii)==collall(jj)
            pairsam = [pairsam; [Mam(rowam(ii),collam(ii)),Mam(collam(ii),rowam(ii)),...
                                 Mall(rowall(jj),collall(jj)),Mall(collall(jj),rowall(jj))]];
        end
    end
end

pairsgd = [];
for ii = 1:numel(collgd)
    for jj = 1:numel(rowall)
        if rowgd(ii)==rowall(jj) && collgd(ii)==collall(jj)
            pairsgd = [pairsgd; [Mgd(rowgd(ii),collgd(ii)),Mgd(collgd(ii),rowgd(ii)),...
                                 Mall(rowall(jj),collall(jj)),Mall(collall(jj),rowall(jj))]];
        end
    end
end


probam = pairsam(:,1)./(pairsam(:,1)+pairsam(:,2));
proballam =pairsam(:,3)./(pairsam(:,3)+pairsam(:,4));
probgd = pairsgd(:,1)./(pairsgd(:,1)+pairsgd(:,2));
proballgd =pairsgd(:,3)./(pairsgd(:,3)+pairsgd(:,4));

countam=0;
for ii = 1:numel(probam)
    if (probam(ii) >0.5 && proballam(ii)>0.5) || (probam(ii)<0.5 && proballam(ii)<0.5)
        countam = countam +1;
    end
end
pam =  countam/numel(probam);

countgd = 0;
for ii = 1:numel(probgd)
    if probgd(ii) >0.5 && proballgd(ii)>0.5 || (probgd(ii)<0.5 && proballgd(ii)<0.5)
        countgd = countgd +1;
    end
end

pgd =  countgd/numel(proballgd);

