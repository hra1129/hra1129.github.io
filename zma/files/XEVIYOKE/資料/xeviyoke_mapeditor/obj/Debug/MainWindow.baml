   M S B A M L   `   `   `  ����M  Ixeviyoke_mapeditor, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null7 clr-namespace:xeviyoke_mapeditorxeviyoke_mapeditor  5   	   #    xeviyoke_mapeditor.MainWindow   5   	   \ XPresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35R NWindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35W SPresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35D 9http://schemas.microsoft.com/winfx/2006/xaml/presentation    5   	   R NSystem.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089:x,http://schemas.microsoft.com/winfx/2006/xaml     5   	   @d2http://schemas.microsoft.com/expression/blend/2008     5   	   Jmc;http://schemas.openxmlformats.org/markup-compatibility/2006     5   	   2local clr-namespace:xeviyoke_mapeditor     5   	     � Title$  XEVIyoke MapEditor��5   	   $	��500��6$   $
��1100��61   .��5	      � .+�5
   
   �� -   5         ��Name$ canvasMapParts��5
      $
��Left=�6)   $	��128��6D   }�. $��	10,10,0,0q�6e   $	��Top=�6x   $	��512��6�   
���   �.+�5      �� -   5         ��Name$ imageMapParts��5      $��./Page1.bmp��6+   $	��512��6@   $	��424��6L   �� 5      $	��128��6   $	��512��6%   $��2��61   
���   � �� Left$ 0��6U   
 �� Top$ 0��6e   �� 5      -   5         ��Name$ rectMapPartsCursor��5      $��16��64   $��16��6@   $��2��6K   
���  ��$ 0��6m   $ 0��6}   5      �� 5   
   -   5        $ canvasEditArea��5      $
��Left=�6)   $	��352��6D   $��
528,10,0,0q�6Q   $	��Top=�6e   $	��512��6}   
���   �.+�5      �� -   5        $ imageEditArea��5      $	��512��6+   $	��352��67   �� 5      $	��352��6   $	��512��6%   $��2��61   
���   �$ 0��6U   $ 0��6e   �� 5      -   5        $ rectEditAreaCursor��5      $��16��64   $��16��6@   $��2��6K   
���  ��$ 0��6m   $ 0��6}   5      �� 5   
   -   5         ��Name$ buttonLoadParts��5      $��Load Parts Image��6*   $
��Left=�6E   $��32��6`   $��
10,157,0,0q�6l   $	��Top=�6�   $	��144��6�   6�   �� 5   
   -   5        $ buttonSaveMap��5      $��Save Map��6(   $
��Left=�6;   $��32��6V   $��
10,293,0,0q�6b   $	��Top=�6v   $	��144��6�   6�   �� 5   
   -	   5        $ buttonLoadMap��5      $��Load Map��6(   $
��Left=�6;   $��32��6V   $��
10,330,0,0q�6b   $	��Top=�6v   $	��144��6�   6�   �� 5   
   -
   5        $ buttonScrollUp��5      $��Up��6)   $
��Left=�66   $��32��6Q   $��528,367,0,0q�6]   $	��Top=�6r   $	��144��6�   6�   �� 5   
   -   5        $ buttonScrollDown��5      $
��Down��6+   $
��Left=�6:   $��32��6U   $��896,367,0,0q�6a   $	��Top=�6v   $	��144��6�   6�   �� 5   
   -   5         ��Name$ labelScrollPosY��5      $��0��6)   $
��Left=�65   $��32��6P   $��683,367,0,0q�6\   $	��Top=�6q   $	��202��6�   $��Center=�6�   $��Center=�6�   5      5      