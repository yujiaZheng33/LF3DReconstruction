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
    // 水平翻转
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

    //去噪滤波处理
    //一、StatisticalOutlierRemoval
    //使用统计分析技术，从一个点云数据中集中移除测量噪声点。对每个点的邻域进行统计分析，剔除不符合一定标准的邻域点。
    // 具体来说：
    //1.对于每个点，计算它到所有相邻点的平均距离。假设得到的分布是高斯分布，我们可以计算出一个均值μ和一个标准差σ；
    //2.这个邻域点集中所有点与其邻域距离大于μ+std_mul*σ区间之外的点都可以被视为离群点，并可从点云数据中去除。
    //std_mul 是标准差倍数的一个阈值，可以自己指定。
    /*
    pcl::PointCloud<PointT>::Ptr cloud_filtered(new pcl::PointCloud<PointT>);
    pcl::StatisticalOutlierRemoval<pcl::PointXYZRGB> sor; //创建滤波器对象
    sor.setInputCloud(cloud);                 //设置待滤波的点云
    sor.setMeanK(50);                         //设置在进行统计时考虑的临近点个数
    sor.setStddevMulThresh(1.0);              //设置判断是否为离群点的阀值，用来倍乘标准差，也就是上面的std_mul
    sor.filter(*cloud_filtered);              //滤波结果存储到cloud_filtered

    //二、RadiusOutlierRemoval
    //pcl::RadiusOutlierRemoval<pcl::PointXYZRGB> pcFilter;  //创建滤波器对象
    //pcFilter.setInputCloud(cloud_filtered);             //设置待滤波的点云
    //pcFilter.setRadiusSearch(0.8);               // 设置搜索半径
    //pcFilter.setMinNeighborsInRadius(2);      // 设置一个内点最少的邻居数目
    //pcFilter.filter(*cloud_filtered);        //滤波结果存储到cloud_filtered

    //三、Bilateral filter
    //双边滤波（Bilateral filter）是一种非线性的滤波方法，是结合图像的空间邻近度和像素值相似度的一种折中处理，
    //同时考虑空域信息和灰度相似性，达到保边去噪的目的。具有简单、非迭代、局部的特点 。
    //双边滤波器的好处是可以做边缘保存。
    float sigma_s = 1.5;
    float sigma_r = 1.5;
    pcl::PointCloud<PointT>::Ptr cloud_filtered2(new pcl::PointCloud<PointT>);
    pcl::FastBilateralFilter<pcl::PointXYZRGB> fbf;
    fbf.setInputCloud(cloud_filtered);
    fbf.setSigmaS(sigma_s);//设置双边滤波器用于空间邻域/窗口的高斯的标准偏差
    fbf.setSigmaR(sigma_r);//设置高斯的标准偏差用于控制相邻像素由于强度差异而下降多少（在我们的情况下为深度）
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

