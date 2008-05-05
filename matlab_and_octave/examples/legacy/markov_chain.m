seqlen=100;
numseq=50000;
order=2; %max 8, markov chain has in fact of order-1 
ppseudo=1e-5;
npseudo=10;

motifidx=10:21;

acgt='ACGT';
rand('state', 17);
LT=[-ones(1,numseq), ones(1,numseq)];
XT=acgt(ceil(3*rand(seqlen,2*numseq)));
XT(motifidx,LT==1)='T';

LV=[-ones(1,numseq), ones(1,numseq)];
XV=acgt(ceil(3*rand(seqlen,2*numseq)));
XV(motifidx,LV==1)='T';

%sg('send_command', 'loglevel ALL');
sg('set_features', 'TRAIN', XT(:,LT==1), 'DNA') ;
sg('send_command', sprintf('convert TRAIN STRING CHAR STRING WORD %i',order));
sg('send_command', sprintf('pseudo %f',ppseudo));
sg('send_command', sprintf('new_hmm %i %i', size(XT,1), 4^order));
sg('send_command', 'linear_train');
[p_p,q_p,a_p,b_p]=sg('get_hmm');
sg('set_features', 'TEST', XV, 'DNA') ;
sg('send_command', sprintf('convert TEST STRING CHAR STRING WORD %i',order));

posout=sg('one_class_linear_hmm_classify');

sg('set_features', 'TRAIN', XT(:,LT==-1), 'DNA');

sg('send_command', sprintf('convert TRAIN STRING CHAR STRING WORD %i',order));
sg('send_command', sprintf('pseudo %f', npseudo));
sg('send_command', sprintf('new_hmm %i %i', size(XT,1), 4^order));
sg('send_command', 'linear_train');
[p_n,q_n,a_n,b_n]=sg('get_hmm');
sg('set_features', 'TEST', XV, 'DNA') ;
sg('send_command', sprintf('convert TEST STRING CHAR STRING WORD %i',order));

negout=sg('one_class_linear_hmm_classify');
output=posout-negout;
err=mean(sign(output)~=LV)
