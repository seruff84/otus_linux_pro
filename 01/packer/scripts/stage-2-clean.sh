 #!/usr/bin/env bash  
sudo apt clean && sudo apt autoclean
rm  -rf ~/linux-6.1.69
sudo rm -rf /tmp/*
sudo rm  -f /var/log/wtmp /var/log/btmp
sudo rm -rf /var/cache/* /usr/share/doc/*
sudo rm -rf /vagrant/home/*.iso
sudo rm  -f ~/.bash_history
history -c
sudo history -c
sudo rm -rf /run/log/journal/*
sudo sync

