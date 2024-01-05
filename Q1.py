import pandas as pd

original_file = pd.read_csv('D:\\Study\\Computing\\发射机与目标机判定\\data\\51st Bisons vs CNF Rd 1__1HZ.csv')
Ids = original_file['Id'].values
names = []

for Id in Ids:
    found = False
    type_name = original_file.loc[original_file['Id'] == Id]['Type'].values[0]
    if type_name.find('Air') == -1:
        continue
    for name in names:
        if Id == name:
            found = True
            break
    if not found:
        names.append(Id)

print(names)