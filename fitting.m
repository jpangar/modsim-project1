
tab_data = readtable("Weekly_United_States_COVID-19_Cases_and_Deaths_by_State_-_ARCHIVED_20261001.csv", "Delimiter", ",");
if ~isdatetime(tab_data.start_date)
    tab_data.start_date = datetime(tab_data.start_date, "InputFormat", "M/d/yyyy");
end
weekly = groupsummary(tab_data, "start_date", "sum", ["new_cases", "new_deaths"]);

startIdx = find(weekly.start_date == datetime(2021,1,21));
%Variable rate every 4 weeks
blockWeeks = 4;   
nBlocks = 4;
%1/21 to 5/6, 4 months total
nWeeks = blockWeeks*nBlocks;  

dataWeeks = weekly.start_date(startIdx : startIdx+nWeeks-1)';
dataCases = weekly.sum_new_cases(startIdx : startIdx+nWeeks-1)';
dataDeaths = weekly.sum_new_deaths(startIdx : startIdx+nWeeks-1)';
prevWeekDeaths = weekly.sum_new_deaths(startIdx-1);

PinfValues = 0.05:0.01:1;

schedule = [];
for b = 1:nBlocks
    nw = b*blockWeeks;
    blockErrors = zeros(size(PinfValues));
    %parameter sweep all values
    for i = 1:length(PinfValues)
        modelCases = runModel([schedule, PinfValues(i)], blockWeeks, nw, prevWeekDeaths);
        blockErrors(i) = sum((log(modelCases) - log(dataCases(1:nw))).^2);
    end
    [~, best] = min(blockErrors);
    schedule = [schedule, PinfValues(best)];
end
[varCases, varDeaths] = runModel(schedule, blockWeeks, nWeeks, prevWeekDeaths);


function [weeklyCases, weeklyDeaths] = runModel(schedule, blockWeeks, nWeeks, prevWeekDeaths)
    young = Subpopulation(0.5, 0.0132, schedule(1), 0.9965/7, 0.0035/7, 0.0033, ...
                          19000000, 0, 258141000, 1155000, 0);
    old = Subpopulation(0.5, 0.0414, schedule(1), 0.911/7, 0.089/7, 0.0033, ...
                        3700000, 0, 50378000, 225000, 0);
    model = COVIDModel(young, old, 0.5, 0.2);
    vaccinesPerDay = 1000000;

    days = 7*nWeeks;
    dailyCases = zeros(1, days);
    dailyDeaths = zeros(1, days);
    for day = 1:days
        Pinf = schedule(min(ceil(day/(7*blockWeeks)), length(schedule)));
        young.Pinfectivity_risk = Pinf;
        old.Pinfectivity_risk = Pinf;

        % from paper
        if old.numVaccinated < 0.8*old.getPopulation()
            youngShare = 0.5;
        else
            youngShare = 1;
        end
        young.Pvaccinated = vaccineFraction(young, youngShare*vaccinesPerDay);
        old.Pvaccinated = vaccineFraction(old, (1-youngShare)*vaccinesPerDay);

        model.simulateAction(day);
        dailyCases(day) = young.newCases + old.newCases;
        dailyDeaths(day) = young.newDeaths + old.newDeaths;
    end
    
    %comptue weeklycases and deaths
    avgDeaths = prevWeekDeaths / 7;
    dailyDeaths = [avgDeaths * ones(1,7), dailyDeaths(1:end-7)];
    
    weeklyCases = sum(reshape(dailyCases, 7, nWeeks), 1);
    weeklyDeaths = sum(reshape(dailyDeaths, 7, nWeeks), 1);
end

function P = vaccineFraction(subpopulation, vaccines)
    eligible = subpopulation.numNaive + subpopulation.numPostInfection;
    P = min(vaccines / eligible, 1 - subpopulation.Pcontact);
end
