#include <iostream>
#include <opencv2/opencv.hpp>
#include <pcl/surface/mls.h>
#include <pcl/kdtree/kdtree_flann.h>
#include <pcl/point_types.h>
#include <pcl/io/io.h>
#include <pcl/io/pcd_io.h>
#include <pcl/visualization/cloud_viewer.h>
#include <pcl/filters/statistical_outlier_removal.h>
#include <pcl/filters/radius_outlier_removal.h>
#include <pcl/filters/fast_bilateral.h>

#include <pcl/common/io.h>

typedef pcl::PointXYZRGB PointT;
using namespace std;

void viewerOneOff(pcl::visualization::PCLVisualizer& viewer)
{
    viewer.setBackgroundColor(0.0, 0.0, 0.0);
}

int main()
{
    pcl::PointCloud<PointT> cloud_a;
    //pcl::PointCloud<PointT>::Ptr cloud;
    pcl::PointCloud<PointT>::Ptr cloud(new pcl::PointCloud<PointT>);

    cv::Mat color = cv::imread("input\\c4.png");
    //cv::Mat depth = cv::imread("input\\spogama.png", CV_8UC1);//
    cv::Mat depth = cv::imread("input\\d4.png", CV_8UC1);//           
    //cv::rotate(color, color, 1);
    //cv::rotate(depth, depth, 1);
    // ˮƽ��ת
    cv::flip(color, color, 0);
    cv::flip(depth, depth, 0);

    int rowNumber = color.rows;
    int colNumber = color.cols;

    cloud_a.height = rowNumber;
    cloud_a.width = colNumber;
    cloud_a.points.resize(cloud_a.width * cloud_a.height);

    for (unsigned int u = 0; u < rowNumber; ++u)
    {
        for (unsigned int v = 0; v < colNumber; ++v)
        {
            unsigned int num = u * colNumber + v;
            double Xw = 0, Yw = 0, Zw = 0;

            Zw = ((double)depth.at<uchar>(u, v) - 255);
            Xw = double(u) - double(rowNumber / 2); //shift image center 
            Yw = double(v) - double(colNumber / 2);

            cloud_a.points[num].b = color.at<cv::Vec3b>(u, v)[0];
            cloud_a.points[num].g = color.at<cv::Vec3b>(u, v)[1];
            cloud_a.points[num].r = color.at<cv::Vec3b>(u, v)[2];

            cloud_a.points[num].x = Yw;
            cloud_a.points[num].y = Xw;
            cloud_a.points[num].z = Zw * 0.7;

        }
    }
    *cloud = cloud_a;

    //ȥ���˲�����
    //һ��StatisticalOutlierRemoval
    //ʹ��ͳ�Ʒ�����������һ�����������м����Ƴ����������㡣��ÿ������������ͳ�Ʒ������޳�������һ����׼������㡣
    // ������˵��
    //1.����ÿ���㣬���������������ڵ��ƽ�����롣����õ��ķֲ��Ǹ�˹�ֲ������ǿ��Լ����һ����ֵ�̺�һ����׼��ң�
    //2.�������㼯�����е��������������ڦ�+std_mul*������֮��ĵ㶼���Ա���Ϊ��Ⱥ�㣬���ɴӵ���������ȥ����
    //std_mul �Ǳ�׼�����һ����ֵ�������Լ�ָ����
    /*
    pcl::PointCloud<PointT>::Ptr cloud_filtered(new pcl::PointCloud<PointT>);
    pcl::StatisticalOutlierRemoval<pcl::PointXYZRGB> sor; //�����˲�������
    sor.setInputCloud(cloud);                 //���ô��˲��ĵ���
    sor.setMeanK(50);                         //�����ڽ���ͳ��ʱ���ǵ��ٽ������
    sor.setStddevMulThresh(1.0);              //�����ж��Ƿ�Ϊ��Ⱥ��ķ�ֵ���������˱�׼�Ҳ���������std_mul
    sor.filter(*cloud_filtered);              //�˲�����洢��cloud_filtered

    //����RadiusOutlierRemoval
    //pcl::RadiusOutlierRemoval<pcl::PointXYZRGB> pcFilter;  //�����˲�������
    //pcFilter.setInputCloud(cloud_filtered);             //���ô��˲��ĵ���
    //pcFilter.setRadiusSearch(0.8);               // ���������뾶
    //pcFilter.setMinNeighborsInRadius(2);      // ����һ���ڵ����ٵ��ھ���Ŀ
    //pcFilter.filter(*cloud_filtered);        //�˲�����洢��cloud_filtered

    //����Bilateral filter
    //˫���˲���Bilateral filter����һ�ַ����Ե��˲��������ǽ��ͼ��Ŀռ��ڽ��Ⱥ�����ֵ���ƶȵ�һ�����д���
    //ͬʱ���ǿ�����Ϣ�ͻҶ������ԣ��ﵽ����ȥ���Ŀ�ġ����м򵥡��ǵ������ֲ����ص� ��
    //˫���˲����ĺô��ǿ�������Ե���档
    float sigma_s = 1.5;
    float sigma_r = 1.5;
    pcl::PointCloud<PointT>::Ptr cloud_filtered2(new pcl::PointCloud<PointT>);
    pcl::FastBilateralFilter<pcl::PointXYZRGB> fbf;
    fbf.setInputCloud(cloud_filtered);
    fbf.setSigmaS(sigma_s);//����˫���˲������ڿռ�����/���ڵĸ�˹�ı�׼ƫ��
    fbf.setSigmaR(sigma_r);//���ø�˹�ı�׼ƫ�����ڿ���������������ǿ�Ȳ�����½����٣������ǵ������Ϊ��ȣ�
    fbf.filter(*cloud_filtered2);
    */
    

    //std::cout << cloud_filtered->size() << std::endl;
    pcl::visualization::CloudViewer viewer("Cloud Viewer");
    viewer.showCloud(cloud);

    //viewer.runOnVisualizationThreadOnce(viewerOneOff);

    while (!viewer.wasStopped())
    {

    }

    return 0;
    // delete cloud;

}

