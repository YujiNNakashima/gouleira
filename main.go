package main

import (
	"database/sql"
	"fmt"
	"html/template"
	"log"
	"net/http"

	_ "github.com/mattn/go-sqlite3"
)

type Film struct {
	Title    string
	Director string
}

func main() {
	fmt.Println("Starting the application...")

	db, err := sql.Open("sqlite3", "your_database.db")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		films, err := queryFilmsFromDB(db)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		renderTemplate(w, films)
	})

	fmt.Println("Server is running on localhost:8080...")
	log.Fatal(http.ListenAndServe("localhost:8080", nil))
}

func queryFilmsFromDB(db *sql.DB) ([]Film, error) {
	rows, err := db.Query("SELECT title, director FROM films")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var films []Film

	for rows.Next() {
		var film Film
		if err := rows.Scan(&film.Title, &film.Director); err != nil {
			return nil, err
		}
		films = append(films, film)
	}

	return films, nil
}

func renderTemplate(w http.ResponseWriter, films []Film) {
	tmpl := template.Must(template.ParseFiles("index.html"))

	data := map[string][]Film{"Films": films}

	if err := tmpl.Execute(w, data); err != nil {
		log.Println("Template rendering error:", err)
		http.Error(w, "Internal Server Error", http.StatusInternalServerError)
	}
}
