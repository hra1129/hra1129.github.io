using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using Microsoft.Win32;
using System.IO;

namespace xeviyoke_mapeditor {
    /// <summary>
    /// MainWindow.xaml の相互作用ロジック
    /// </summary>
    public partial class MainWindow: Window {
        int nPartsNo = 0;
        BitmapImage bmpMapPartsBase;
        RenderTargetBitmap[] bmpMapParts;
        RenderTargetBitmap bmpEditArea;
        byte[] MapData;
        int ScrollPosY = 21;

        public MainWindow() {
            InitializeComponent();

            int width = 256;
            int height = 176;
            PixelFormat pf = PixelFormats.Pbgra32;

            bmpEditArea = new RenderTargetBitmap( width, height, 96, 96, pf );
            imageEditArea.Source = bmpEditArea;

            bmpMapParts = new RenderTargetBitmap[ 256 ];
            for( int i = 0; i < 256; i++ ) {
                bmpMapParts[ i ] = new RenderTargetBitmap( 8, 8, 96, 96, pf );
            }

            MapData = new byte[ 7 + 32 * 768 ];
            //  BSAVE Header
            MapData[ 0 ] = 0xFE;
            MapData[ 1 ] = 0x00;
            MapData[ 2 ] = 0x00;
            MapData[ 3 ] = 0xFF;
            MapData[ 4 ] = 0x5F;
            MapData[ 5 ] = 0x00;
            MapData[ 6 ] = 0x00;
        }

		private void CanvasMapParts_MoveCursor() {
			int x = nPartsNo & 31;
			int y = nPartsNo >> 5;
			Canvas.SetLeft( rectMapPartsCursor, x * 16 );
			Canvas.SetTop( rectMapPartsCursor, y * 16 );
		}
		private void CanvasMapParts_MouseLeftButtonDown( object sender, MouseButtonEventArgs e ) {
            Canvas c = sender as Canvas;
            Point pos = e.GetPosition( c );
            int x = (int)pos.X & ~15;
            int y = (int)pos.Y & ~15;
            nPartsNo = ( x >> 4 ) + ( y << 1 );
			CanvasMapParts_MoveCursor();
        }
		private int CanvasEditArea_SetParts( int x, int y, int PartsNo ) {
			x = x >> 3;
			y = y >> 3;
			if( x < 0 ) {
				x = 0;
			}
			if( x > 31 ) {
				x = 31;
			}
			if( y < 0 ) {
				y = 0;
			}
			if( y > 21 ) {
				y = 21;
			}
			int abs_y = ScrollPosY - y;
			if( abs_y < 0 ) {
				return 0;
			}
			MapData[ 7 + abs_y * 32 + x ] = (byte)PartsNo;
			return PartsNo;
		}
		private void CanvasEditArea_PutParts( int x, int y, int PartsNo ) {
			DrawingVisual dv;
			DrawingContext dc;
			dv = new DrawingVisual();
			dc = dv.RenderOpen();
			Rect rect = new Rect( new Point( x, y ), new Size( 8, 8 ) );
			dc.DrawImage( bmpMapParts[ PartsNo ], rect );
			dc.Close();
			bmpEditArea.Render( dv );
		}
		private int CanvasEditArea_getParts( int x, int y ) {
			x = x >> 3;
			y = y >> 3;
			if( x < 0 ) {
				x = 0;
			}
			if( x > 31 ) {
				x = 31;
			}
			if( y < 0 ) {
				y = 0;
			}
			if( y > 21 ) {
				y = 21;
			}
			int abs_y = ScrollPosY - y;
			if( abs_y < 0 ) {
				return 0;
			}
			return MapData[ 7 + abs_y * 32 + x ];
		}
		private void CanvasEditArea_UpdateView() {
            int x, y, abs_y, PartsNo;
            for( y = 0; y < 22; y++ ) {
                abs_y = ScrollPosY - y;
                for( x = 0; x < 32; x++ ) {
                    if( abs_y < 0 ) {
                        PartsNo = 0;
                    }
                    else {
						PartsNo = MapData[ 7 + abs_y * 32 + x ];
                    }
					CanvasEditArea_PutParts( x * 8, y * 8, PartsNo );
				}
            }
			labelScrollPosY.Content = ScrollPosY.ToString();
		}
        private void ButtonLoadParts_Click( object sender, RoutedEventArgs e ) {
            var dialog = new OpenFileDialog();
            dialog.Filter = "画像ファイル (*.bmp)|*.bmp|すべてのファイル (*.*)|*.*";
            if( dialog.ShowDialog() != true ) {
                return;
            }

            bmpMapPartsBase = new BitmapImage();
            bmpMapPartsBase.BeginInit();
            bmpMapPartsBase.CacheOption = BitmapCacheOption.OnLoad;
            bmpMapPartsBase.DecodePixelWidth = 256;
            bmpMapPartsBase.DecodePixelHeight = 212;
            bmpMapPartsBase.UriSource = new Uri( dialog.FileName, UriKind.Relative );
            bmpMapPartsBase.EndInit();

            imageMapParts.Source = bmpMapPartsBase;

            DrawingVisual dv;
            DrawingContext dc;
            dv = new DrawingVisual();
            for( int i = 0; i < 256; i++ ) {
                dc = dv.RenderOpen();
                int px = ( i & 31 ) * 8;
                int py = ( i >> 5 ) * 8;
                Rect rect = new Rect( new Point( -px, -py ), new Size( 256, 212 ) );
                dc.DrawImage( bmpMapPartsBase, rect );
                dc.Close();
                bmpMapParts[ i ].Render( dv );
            }
            CanvasEditArea_UpdateView();
        }

        private Point calc_EditAreaPosition( object sender, MouseEventArgs e ) {
            Canvas c = sender as Canvas;
            Point pos = e.GetPosition( c );
            int x = (int)pos.X & ~15;
            int y = (int)pos.Y & ~15;
            if( x >= 512 ) {
                x = 512 - 16;
            }
            if( x < 0 ) {
                x = 0;
            }
            if( y >= 352 ) {
                y = 352 - 16;
            }
            if( y < 0 ) {
                y = 0;
            }
            pos.X = x;
            pos.Y = y;
            return pos;
        }

        private void CanvasEditArea_MouseMove( object sender, MouseEventArgs e ) {
            Point pos = calc_EditAreaPosition( sender, e );
            Canvas.SetLeft( rectEditAreaCursor, pos.X );
            Canvas.SetTop( rectEditAreaCursor, pos.Y );

            if( e.LeftButton == MouseButtonState.Pressed ) {
				int PartsNo = CanvasEditArea_SetParts( (int)( pos.X / 2 ), (int)( pos.Y / 2 ), nPartsNo );
				CanvasEditArea_PutParts( (int)( pos.X / 2 ), (int)( pos.Y / 2 ), PartsNo );
            }
        }

        private void CanvasEditArea_MouseLeftButtonDown( object sender, MouseButtonEventArgs e ) {
            Point pos = calc_EditAreaPosition( sender, e );
            Canvas.SetLeft( rectEditAreaCursor, pos.X );
            Canvas.SetTop( rectEditAreaCursor, pos.Y );

			int PartsNo = CanvasEditArea_SetParts( (int)( pos.X / 2 ), (int)( pos.Y / 2 ), nPartsNo );
			CanvasEditArea_PutParts( (int)( pos.X / 2 ), (int)( pos.Y / 2 ), PartsNo );
        }

		private void CanvasEditArea_MouseRightButtonDown( object sender, MouseButtonEventArgs e ) {
			Point pos = calc_EditAreaPosition( sender, e );
			Canvas.SetLeft( rectEditAreaCursor, pos.X );
			Canvas.SetTop( rectEditAreaCursor, pos.Y );

			nPartsNo = CanvasEditArea_getParts( (int)( pos.X / 2 ), (int)( pos.Y / 2 ) );
			CanvasMapParts_MoveCursor();
		}

		private void ButtonScrollUp_Click( object sender, RoutedEventArgs e ) {
			ScrollPosY++;
			if( ScrollPosY >= 768 ) {
				ScrollPosY = 0;
			}
			CanvasEditArea_UpdateView();
		}

		private void ButtonScrollDown_Click( object sender, RoutedEventArgs e ) {
			ScrollPosY--;
			if( ScrollPosY < 0 ) {
				ScrollPosY = 767;
			}
			CanvasEditArea_UpdateView();
		}

		private void ButtonSaveMap_Click( object sender, RoutedEventArgs e ) {
			var dialog = new SaveFileDialog();
			dialog.Filter = "マップファイル (*.sc5)|*.sc5|すべてのファイル (*.*)|*.*";
			if( dialog.ShowDialog() != true ) {
				return;
			}

			using( var fs = new FileStream( dialog.FileName, FileMode.Create ) ) {
				fs.Write( MapData, 0, MapData.Length );
			}
		}

		private void ButtonLoadMap_Click( object sender, RoutedEventArgs e ) {
			var dialog = new OpenFileDialog();
			dialog.Filter = "マップファイル (*.sc5)|*.sc5|すべてのファイル (*.*)|*.*";
			if( dialog.ShowDialog() != true ) {
				return;
			}

			using( var fs = new FileStream( dialog.FileName, FileMode.Open ) ) {
				fs.Read( MapData, 0, MapData.Length );
			}
			CanvasEditArea_UpdateView();
		}
	}
}
