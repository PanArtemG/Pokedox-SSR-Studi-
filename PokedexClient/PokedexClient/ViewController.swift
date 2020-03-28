//
//  ViewController.swift
//  PokedexClient
//
//  Created by Artem Panasenko on 28.03.2020.
//  Copyright © 2020 Artem Panasenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum Result <T> {
        case succsess(T)
        case falure(Error)
    }

    @IBOutlet weak var tableViev: UITableView!
    
    var pokemons: [Pokemon] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViev.dataSource = self
        
        getPokemons { [weak self] (result) in
            switch result {
            case .succsess(let pokemons):
                self?.pokemons = pokemons
                DispatchQueue.main.async {[weak self] in
                    self?.tableViev.reloadData()
                }
            case .falure(let error):
                let alert  = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
                    self?.dismiss(animated: true, completion: nil)
                })
                alert.addAction(ok)
                
                self?.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    private func getPokemons(completion: @escaping (Result<[Pokemon]>) -> ()) {
        let url = URL(string: "http://localhost:8080/pokemons")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.falure(error))
                return
            }
            
            do {
                let pokmons = try JSONDecoder().decode([Pokemon].self, from: data!)
                completion(.succsess(pokmons))
            } catch {
                completion(.falure(error))
            }
        }.resume() // запуск задачи
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let pokemon = pokemons[indexPath.row]
        cell.textLabel?.text = pokemon.name
        
        return cell
    }
}
