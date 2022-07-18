//
//  EvenViewController.swift
//  Infinite Scroll
//
//  Created by Misha on 16.07.2022.
//

import UIKit

class EvenViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate {
    
    private let apiCaller = APICaller()
    
    private let fibonacciButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.backgroundColor = UIColor.blue
        button.setTitle("Числа Фиббоначи", for: .normal)
        button.addTarget(self, action: #selector(fibonacciButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let collectionView: UICollectionView  = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CustomCell.self,
                                forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    private var count = 1
    
    private var data = [Int]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Простые числа"
        view.backgroundColor = .white
        view.addSubview(collectionView)
        view.addSubview(fibonacciButton)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupConstraints()
        
        apiCaller.fetchData(pagination: false, completion: { [weak self] result in
            switch result {
            case.success(let data):
                self?.data.append(contentsOf: data)
                while true {
                    self?.count += 1
                    self?.data.append(self?.count ?? 99)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        self?.collectionView.reloadData()
                    }
                    
                    if self?.count == 50 {
                        break
                    }
                }
            case.failure(_):
                break
            }
        })
    }
    
    func setupConstraints() {
        
        fibonacciButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        fibonacciButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        fibonacciButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        fibonacciButton.widthAnchor.constraint(equalToConstant: view.frame.width - 15).isActive = true
        
        collectionView.topAnchor.constraint(equalTo: fibonacciButton.bottomAnchor, constant: 10).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
    }
    
    //MARK: -TableViewDelegate, TableViewDataSoure
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2.5, height: collectionView.frame.width/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        cell.numberLabel.text =  String(describing: data[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cellColors = [UIColor.gray, UIColor.white, UIColor.white, UIColor.gray]
        cell.backgroundColor = cellColors[indexPath.row % cellColors.count]
        
    }

    //MARK: -ScrollView
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (collectionView.contentSize.height-100-scrollView.frame.size.height) {
            guard !apiCaller.isPaginating else { return }
            apiCaller.fetchData(pagination: true) { [weak self] result in
                switch result {
                case .success(let moreData):
                    let last = self?.data.last
                    let lastPlusOne = (last ?? 99) + 1
                    self?.data.append(lastPlusOne)
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
    
    //MARK: -Selectors
    
    @objc func fibonacciButtonPressed() {
        let fibonacciViewController = FibonacciViewController()
        navigationController?.pushViewController(fibonacciViewController, animated: true)
    }
}

