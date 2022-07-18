//
//  FibonacciViewController.swift
//  Infinite Scroll
//
//  Created by Misha on 18.07.2022.
//

import Foundation
import UIKit

class FibonacciViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate {
    
    private let apiCaller = APICaller()
    
    private let collectionView: UICollectionView  = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CustomCell.self,
                                forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    private var count = 7
    
    private var data = [Int]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Числа Фиббоначи"
        view.backgroundColor = .white
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        setupConstraints()
        
        apiCaller.fetchData(pagination: false, completion: { [weak self] result in
            switch result {
            case.success(let data):
                self?.data.append(contentsOf: data)
                //Распечатываем имеющийся до функции массив
                print("Начальный массив в фибоначчи:\(data)")
                //while true {
                    //Gередаём в функцию фибоначчи 1
                    let newValue = self?.fibonacci(numSteps: self?.count ?? 1)
                    print("Значение в фибоначчи:\(newValue)")
                    //Добавляем в массив значение фиббоначи
                    self?.data = newValue ?? [0,1]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        self?.collectionView.reloadData()
                    }
                    
//                    if newValue?.count == 10 {
//                        break
//                    }
                //}
            case.failure(_):
                break
            }
        })
    }
    
    //MARK: -Functions
    func setupConstraints() {
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func fibonacci(numSteps:Int) -> [Int] {
        var sequence = self.data
        for _ in 0..<numSteps - 2 {
            let first = sequence[sequence.count - 2]
            let second = sequence.last!
            sequence.append(first &+ second)
        }
        return sequence
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
                    let newValue = self?.fibonacci(numSteps: last ?? 1)
                    print("NEW VALUE: \(newValue)")
                    self?.data = newValue ?? [0,1]
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                case .failure(_):
                    break
                }
            }
        }
    }
    
}
