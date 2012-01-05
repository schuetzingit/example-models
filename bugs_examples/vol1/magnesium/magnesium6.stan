# Sensitivity to prior distributions: application to Magnesium meta-analysis
#  http://www.openbugs.info/Examples/Magnesium.html


# prior specification 3 
# Half-Normal on sigma^2

data {
  int N; 
  int rc[N]; 
  int rt[N];
  int nc[N]; 
  int nt[N]; 
} 

derived data {
  double s0_sqrd; 
  double psigma; 
  s0_sqrd <- 0.1272041; 
  psigma <- sqrt(s0_sqrd / Phi(.75)); 
} 
#   > print(s0.sqrd);
#   [1] 0.1272041

parameters {
  double(-10, 10) mu;
  double(0, )  sigmasq; 
  double(0, 1) pc[N]; 
  double theta[N]; 
} 

derived parameters {
  double pt[N];
  double sigma;
  sigma <- sqrt(sigmasq); 
 
  for (n in 1:N) 
    pt[n] <- inv_logit(theta[n] + logit(pc[n])); 
    // I.e., logit(pt[n]) - logit(pc[n]) = theta[n] 
} 

model {
  for (n in 1:N) {
    rt[n] ~ binomial(nt[n], pt[n]); 
    rc[n] ~ binomial(nt[n], pc[n]); 
  } 

  # pc ~ uniform(0, 1); // not vectorized? 
  for (n in 1:N) pc[n] ~ uniform(0, 1);

  ## or we can leave out the above line, which contributes
  ## nothing to the posterior

  theta ~ normal(mu, sigma); 
  mu ~ uniform(-10, 10); 

  // prior for sigmasq (Half-normal)
  sigmasq ~ normal(0, psigma); 
} 
