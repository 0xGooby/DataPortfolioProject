import requests
from bs4 import BeautifulSoup
import pandas as pd

def scrape_nhl():
    url = "https://www.scrapethissite.com/pages/forms/?page_num=10"
    response = requests.get(url)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        table = soup.find_all("table", class_="table")[0]
        titles = table.find_all("th")
        table_titles = [title.text.strip() for title in titles]
        df  = pd.DataFrame(columns=table_titles)
        column_data = table.find_all("tr", class_="team")
        for row in column_data[1:]:
            row_data = row.find_all("td")
            indiv_row_data = [data.text.strip() for data in row_data]

            length = len(df)
            df.loc[length] = indiv_row_data
        # df.to_csv(r"C:\Users\Alex Pc\Downloads\Coding Projects\Python Projects\Data Analyst\Test csv files\nhl_data.csv")

    else:
        print("Failed to retrieve nhl data.")

if __name__ == "__main__":
    scrape_nhl()

nhl_csv = pd.read_csv('Test csv files/nhl_data.csv')

value = 0
name = ""

for i in range(len(nhl_csv)):
    each_team_names = nhl_csv.at[i, "Team Name"]
    each_team_wins = nhl_csv.at[i, "Wins"]
    int_win = int(each_team_wins)
    string_name = str(each_team_names)
    if int_win > value:
        value = int_win
        name = each_team_names

print(f"The team with the most wins: {name}  \nWins: {value}")
