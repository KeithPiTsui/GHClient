//: Playground - noun: a place where people can play

import UIKit

import PlaygroundSupport

class ScrollingViewController : UIViewController {

  override func loadView() {

    let contentView = UIView(frame: CGRect(x: 0, y: 0, width: 5000, height: 5000))
    contentView.backgroundColor = .green

    let scrollView = UIScrollView()
    scrollView.contentSize = contentView.frame.size
    scrollView.addSubview(contentView)
    scrollView.flashScrollIndicators()
    scrollView.backgroundColor = .white

    self.view = scrollView

    self.view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
  }

}

PlaygroundPage.current.liveView = ScrollingViewController()
